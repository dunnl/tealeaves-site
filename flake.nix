{
  description = "A flake for building the Tealeaves website";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;
  inputs.tealeaves.url = github:dunnl/tealeaves/new-flakes;
  inputs.tealeaves.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, tealeaves }@inputs:
    let pkgs = import nixpkgs {
          system = "x86_64-linux";
        };
        tealeaves = inputs.tealeaves.packages.x86_64-linux.tealeaves;
        tealeaves-examples = inputs.tealeaves.packages.x86_64-linux.tealeaves-examples;
        generator = pkgs.haskellPackages.callPackage
          (import ./tealeaves-site-generator.nix) {};
        update-examples = pkgs.callPackage
          (import ./tealeaves-update-examples.nix) {
            inherit tealeaves-examples;
          };
        update-docs = pkgs.callPackage
          (import ./tealeaves-update-coqdocs.nix) {
            inherit pkgs tealeaves;
          };
        generator-shell =  pkgs.haskellPackages.shellFor {
          packages = hpkgs: [
            generator
          ];
          nativeBuildInputs = [
            pkgs.cabal-install
            pkgs.cabal2nix
          ];
        };
        site = pkgs.callPackage
          (import ./tealeaves-site.nix) {
            inherit tealeaves tealeaves-examples generator;
          };
        site-app = {
          type = "app";
          program = "${generator}/bin/tealeaves-site-generator";
        };
        update-coqdocs-app = {
          type = "app";
          program = "${update-docs}/bin/tealeaves-update-coqdocs";
        };
        update-examples-app = {
          type = "app";
          program = "${update-examples}/bin/tealeaves-update-examples";
        };
    in { packages.x86_64-linux = {
           default = generator;
           inherit generator update-examples site;
           };
         devShells.x86_64-linux = {
           default = generator-shell;
           generator = generator-shell;
         };
         apps.x86_64-linux = {
           default = site-app;
           site = site-app;
           update-examples = update-examples-app;
           update-docs = update-coqdocs-app;
         };
       };
}
