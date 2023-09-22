{ pkgs ? import nix/nixpkgs-pinned.nix { } }:
pkgs.callPackage ./dbcritic.nix { }
