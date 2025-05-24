{
  mkKdeDerivation,
  qtsvg,
  taglib,
  phonon,
}:
mkKdeDerivation {
  pname = "juk";

  extraBuildInputs = [
    qtsvg
    taglib
    phonon
  ];
  meta.mainProgram = "juk";
}
