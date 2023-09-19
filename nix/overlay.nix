self: super:
let
  sources = import ./sources.nix;
  haskellOverlay = import ./haskell-overlay.nix {
    pkgs = self;
  };
in
{
  sources = if super ? sources then super.sources // sources else sources;
  # Generic haskellPackages since neither Idris nor its dependencies
  # are pinned to a specific GHC version.
  haskellPackages = super.haskellPackages.extend haskellOverlay;
}
