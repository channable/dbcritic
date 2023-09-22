{ pkgs }:
self: super:

{
  dbcritic = self.callPackage ../dbcritic.nix { };
}
