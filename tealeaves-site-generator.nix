{ mkDerivation, base, data-default, directory, filepath, hakyll
, hakyll-sass, lib, pandoc, pandoc-types, nix-gitignore
}:
mkDerivation {
  pname = "tealeaves-site-hakyll";
  version = "0.1.0.0";
  src = nix-gitignore.gitignoreSourcePure ./.gitignore_nix ./.;
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
