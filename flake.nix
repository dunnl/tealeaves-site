{
  description = "A flake for building the Tealeaves website";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;
  inputs.tealeaves.url = github:dunnl/tealeaves/new-flakes;
  inputs.tealeaves.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, tealeaves }@inputs:
    let pkgs = import nixpkgs {
          system = "x86_64-linux";
        };
        generator = pkgs.haskellPackages.callPackage
          (import ./tealeaves-site-generator.nix) {};
        generator-shell =  pkgs.haskellPackages.shellFor {
          packages = hpkgs: [
            generator
          ];
          nativeBuildInputs = [
            pkgs.cabal-install
            pkgs.cabal2nix
          ];
        };
        tealeaves = inputs.tealeaves.packages.x86_64-linux.tealeaves;
        tealeaves-examples = inputs.tealeaves.packages.x86_64-linux.tealeaves-examples;
        site = pkgs.callPackage
          (import ./tealeaves-site.nix) {
            inherit tealeaves tealeaves-examples generator;
          };
    in { packages.x86_64-linux.default = generator;
         packages.x86_64-linux.generator = generator;
         packages.x86_64-linux.site = site;
         devShells.x86_64-linux.default =
           generator-shell;
         devShells.x86_64-linux.generator =
           generator-shell;
         apps.x86_64-linux.default = {
           type = "app";
           program = "${generator}/bin/tealeaves-site-generator";
         };
       };
}
