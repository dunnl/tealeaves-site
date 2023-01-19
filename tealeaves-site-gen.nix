{ mkDerivation, base, data-default, directory, filepath, hakyll
, hakyll-sass, lib, pandoc, pandoc-types, pkgs
}:
mkDerivation {
  pname = "tealeaves-site-gen";
  version = "0.1.0.0";
  src = pkgs.nix-gitignore.gitignoreSourcePure ./.gitignore_nix ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base data-default directory filepath hakyll hakyll-sass pandoc
    pandoc-types
  ];
  executableHaskellDepends = [ base ];
  testHaskellDepends = [ base ];
  homepage = "https://github.com/dunnl/tealeaves-site/";
  description = "Website for the Tealeaves project";
  license = lib.licenses.mit;
}
