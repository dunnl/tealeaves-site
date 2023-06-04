{
  description = "A flake for building the Tealeaves website";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;
  inputs.tealeaves.url = github:dunnl/tealeaves/new-flakes;

  outputs = { self, nixpkgs, tealeaves }:
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
          ];
        };
        site = pkgs.callPackage
          (import ./tealeaves-site.nix) {
            inherit tealeaves generator;
          };
    in { packages.x86_64-linux.default = generator;
         packages.x86_64-linux.generator = generator;
         packages.x86_64-linux.site = site;
         devShells.x86_64-linux.default =
           generator-shell;
         devShells.x86_64-linux.generator =
           generator-shell;
         };
}
