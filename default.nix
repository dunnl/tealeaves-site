# Modified from
# https://www.cs.yale.edu/homes/lucas.paul/posts/2017-04-10-hakyll-on-nix.html
let
  pkgs = import <nixpkgs> {};
  stdenv = pkgs.stdenv;
  callPackage = pkgs.haskellPackages.callPackage;
in
rec {
  coq-tealeaves = (callPackage (import ../tealeaves/default.nix) {}).coq-tealeaves;
  tealeaves-site-hakyll = callPackage (import ./tealeaves-site-hakyll.nix) {};
  tealeaves-site = stdenv.mkDerivation rec {
    name = "tealeaves-site";
    src = ./.;
    phases = "unpackPhase buildPhase";
    version = "0.1";
    buildInputs = [ coq-tealeaves tealeaves-site-hakyll ];
    buildPhase = ''
      export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive";
      export LANG=en_US.UTF-8
      tealeaves-site-hakyll build
      mkdir $out
      cp -r _site/* $out
      mkdir $out/coqdocs/
      # Copy coqdoc-generated outputs to website output
      cp ${coq-tealeaves}/share/coq/${pkgs.coq.coq-version}/coq/user-contrib/Tealeaves/html/* $out/coqdocs/
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
