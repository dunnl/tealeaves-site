# Modified from
# https://www.cs.yale.edu/homes/lucas.paul/posts/2017-04-10-hakyll-on-nix.html
let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
  callPackage = pkgs.haskellPackages.callPackage;
in
rec {
  tealeaves-site-gen = callPackage (import ./tealeaves-site-gen.nix) {};
  tealeaves-site = stdenv.mkDerivation rec {
    name = "tealeaves-site";
    src = ./.;
    phases = "unpackPhase buildPhase";
    version = "0.1";
    buildInputs = [ tealeaves-site-gen ];
    buildPhase = ''
      export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive";
      export LANG=en_US.UTF-8
      tealeaves-site-gen build
      mkdir $out
      cp -r _site/* $out
    '';
    meta = {
      description = "The contents of the Tealeaves project website";
      longDescription = ''
          This package contains the entire set of
          static files that make up the Tealeaves
          project website.
        '';
      homepage = "http://tealeaves.science";
      license = pkgs.lib.licenses.mit;
    };
  };
}
