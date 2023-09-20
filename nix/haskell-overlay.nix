{ pkgs }:
self: super:

{
  # cheapskate is marked broken in nixpkgs.
  cheapskate = with pkgs.haskell.lib;
    markUnbroken (doJailbreak super.cheapskate);
}
