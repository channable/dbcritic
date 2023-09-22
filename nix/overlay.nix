self: super:
let
  sources = import ./sources.nix;
  haskellOverlay = import ./haskell-overlay.nix { pkgs = self; };
  idrisOverlay = import ./idris-overlay.nix { pkgs = self; };
in {
  sources = if super ? sources then super.sources // sources else sources;

  # Generic haskellPackages since neither Idris nor its dependencies
  # are pinned to a specific GHC version.
  haskellPackages = super.haskellPackages.extend haskellOverlay;
  # There's no nice composable way to extend the Idris package overlay
  idrisPackages = super.idrisPackages.override { overrides = idrisOverlay; };

  # Just like fro Idris itself, we'll provide a top-level synonym for the dbcritic package
  dbcritic = self.idrisPackages.dbcritic;
}
