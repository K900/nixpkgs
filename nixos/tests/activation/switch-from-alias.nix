{ pkgs, ... }:
# Test that switching a service that has an alias and is reloadIfChanged (i.e. shouldn't be stopped)
# to another implementation that provides the service name directly, without an alias,
# doesn't kill the already running service.
# This is important for things like dbus.service and display-manager.service,
# which can be replaced via aliases, but should basically never be restarted
# after boot.
# This is an inverse of sorts of the switch-to-alias test.
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
    systemd.services.testing-alt = mkService ["testing.service"];

    specialisation.alt.configuration = {
      systemd.services = {
        testing-alt.enable = false;
        testing = mkService [];
      };
    };
  };

  testScript = ''
    machine.start()

    # Both the alias and the main name point to the alternate implementation
    machine.succeed("systemctl status testing | grep -q testing-alt.service")
    machine.succeed("systemctl status testing-alt")

    machine.succeed("/run/current-system/specialisation/alt/bin/switch-to-configuration switch")

    # We switch back and the alternate implementation keeps running
    machine.succeed("systemctl status testing | grep -q testing-alt.service")
    machine.succeed("systemctl status testing-alt")

    machine.succeed("/run/current-system/bin/switch-to-configuration switch")

    # After switching back, nothing changes.
    machine.succeed("systemctl status testing | grep -q testing-alt.service")
    machine.succeed("systemctl status testing-alt")
  '';
}
