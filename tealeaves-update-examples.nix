{ writeShellScriptBin, tealeaves-examples }:

writeShellScriptBin "tealeaves-update-examples" ''
    rm -Rf site/examples
    mkdir -p site/examples
    cp -r ${tealeaves-examples}/* site/examples/
    find site/examples -type d -exec chmod 0755 {} \;
    find site/examples -type f -exec chmod 0644 {} \;
    sed -i 's/alectryon\.css/\.\.\/alectryon\.css/g' site/examples/STLC/*.html site/examples/SystemF/*.html
    sed -i 's/docutils_basic\.css/\.\.\/docutils_basic\.css/g' site/examples/STLC/*.html site/examples/SystemF/*.html
    sed -i 's/pygments\.css/\.\.\/pygments\.css/g' site/examples/STLC/*.html site/examples/SystemF/*.html
    sed -i 's/alectryon\.js/\.\.\/alectryon\.js/g' site/examples/STLC/*.html site/examples/SystemF/*.html
  ''
