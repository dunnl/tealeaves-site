{ pkgs ? import <nixpkgs> {} }:
pkgs.haskellPackages.shellFor {
  packages = ps: [ (import ./default.nix).tealeaves-site-gen ];
  buildInputs = [ pkgs.haskellPackages.cabal2nix
                  pkgs.haskellPackages.cabal-install ];
}
