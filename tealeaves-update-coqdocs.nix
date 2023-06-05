{ writeShellScriptBin, pkgs, tealeaves }:

writeShellScriptBin "tealeaves-update-coqdocs" ''
    rm -Rf site/coqdocs/
    mkdir -p site/coqdocs/
    cp -r ${tealeaves}/share/coq/${pkgs.coq.coq-version}/user-contrib/Tealeaves/html/* site/coqdocs/
  ''
