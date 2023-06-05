{ stdenv, tealeaves, tealeaves-examples, generator, pkgs }:

stdenv.mkDerivation {
    name = "tealeaves-site";
    src = ./.;
    phases = "unpackPhase buildPhase installPhase";
    version = "0.1";
    buildInputs = [ generator ];
    buildPhase = ''
      export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive";
      export LANG=en_US.UTF-8
      tealeaves-site-generator build
      mkdir $out
      mkdir _site/coqdocs/
      cp -r ${tealeaves}/share/coq/${pkgs.coq.coq-version}/user-contrib/Tealeaves/html/* _site/coqdocs/
      mkdir _site/examples/
      cp -r ${tealeaves-examples}/* _site/examples/
    '';
    installPhase = ''
      cp -a _site/* $out
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
  }
