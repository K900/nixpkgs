{
  mkKdeDerivation,
  kconfigwidgets,
  kxmlgui,
  kparts,
  phonon,
}:
mkKdeDerivation {
  pname = "dragon";

  extraBuildInputs = [
    kconfigwidgets
    kxmlgui
    kparts
    phonon
  ];

  meta.mainProgram = "dragon";
}
