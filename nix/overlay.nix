self: super:
let
  sources = import ./sources.nix;
  haskellOverlay = import ./haskell-overlay.nix {
    inherit sources;
    pkgs = self;
  };
in
{
  sources = if super ? sources then super.sources // sources else sources;
  haskellPackages944 = super.haskell.packages.ghc944.extend haskellOverlay;
}
