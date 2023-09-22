{ pkgs ? import nix/nixpkgs-pinned.nix { } }:

pkgs.mkShell { inputsFrom = with pkgs; [ dbcritic ]; }
