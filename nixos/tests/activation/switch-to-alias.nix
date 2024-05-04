{ pkgs, ... }:
# Test that switching a service that is reloadIfChanged (i.e. shouldn't be stopped)
# to another implementation that provides an alias doesn't actually kill the service.
# This is important for things like dbus.service and display-manager.service,
# which can be replaced via aliases, but should basically never be restarted
# after boot.
# This is an inverse of sorts of the switch-from-alias test.
{
  name = "unit-aliases";

  nodes.machine = let
    mkService = aliases: {
      script = "${pkgs.coreutils}/bin/sleep 1000000";
      wantedBy = ["multi-user.target"];
      reloadIfChanged = true;
      serviceConfig.ExecReload = "${pkgs.coreutils}/bin/true";
      inherit aliases;
    };
  in {
    systemd.services.testing = mkService [];

    specialisation.alt.configuration = {
      systemd.services = {
        testing.enable = false;
        testing-alt = mkService ["testing.service"];
      };
    };
  };

  testScript = ''
    machine.start()

    machine.succeed("systemctl status testing")

    machine.succeed("/run/current-system/specialisation/alt/bin/switch-to-configuration switch")

    # Even after attempting to switch to the alternate implementation,
    # the main one should keep running, as we stated we should not stop it.
    machine.succeed("systemctl status testing")
    machine.fail("systemctl status testing-alt")

    machine.succeed("/run/current-system/bin/switch-to-configuration switch")

    # After switching back, nothing changes.
    machine.succeed("systemctl status testing")
    machine.fail("systemctl status testing-alt")
  '';
}
