{
  mkKdeDerivation,
  pkg-config,
  plasma-workspace,
  qtwebengine,
  libcec,
  libcec_platform,
  sdl3,
}:

mkKdeDerivation {
  pname = "plasma-bigscreen";

  patches = [
    ./keyboard-desktop-path.patch
    ./wallpaper-paths.patch
  ];

  postPatch = ''
    substituteInPlace bin/plasma-bigscreen-wayland.in \
      --replace-fail @KDE_INSTALL_FULL_LIBEXECDIR@ "${plasma-workspace}/libexec"

    substituteInPlace bin/plasma-bigscreen-wayland.desktop.cmake \
      --replace-fail @CMAKE_INSTALL_FULL_LIBEXECDIR@ "${plasma-workspace}/libexec"
  '';

  extraCmakeFlags = [
    "-DQT_FIND_PRIVATE_MODULES=ON"
  ];

  extraNativeBuildInputs = [
    pkg-config
  ];

  extraBuildInputs = [
    qtwebengine

    libcec
    libcec_platform
    sdl3
  ];

  dontQmlLint = true;

  preFixup = ''
    substituteInPlace "$out"/bin/plasma-bigscreen-common-env \
      --replace-fail "plasma-bigscreen-envmanager" "$out/bin/plasma-bigscreen-envmanager"

    substituteInPlace "$out"/bin/plasma-bigscreen-{wayland,swap-session} \
      --replace-fail "plasma-bigscreen-common-env" "$out/bin/plasma-bigscreen-common-env"
  '';

  passthru.providedSessions = [ "plasma-bigscreen-wayland" ];
}
