self: super:
let
  sources = import ./sources.nix;
  haskellOverlay = import ./haskell-overlay.nix { pkgs = self; };
in {
  sources = if super ? sources then super.sources // sources else sources;


  # Idris does not build on GHC > 9.4
  haskellPackagesDbcritic = super.haskell.packages.ghc94.extend haskellOverlay;
  idrisPackagesDbcritic = super.idrisPackages.override {
    idris-no-deps = self.haskellPackagesDbcritic.idris;
  };
  idrisDbcritic = self.idrisPackagesDbcritic.with-packages [
    self.idrisPackagesDbcritic.base
  ];

  # We can't add dbcritic to the Idris packages overlay because it's not a
  # proper Idris package
  dbcritic = self.callPackage ../dbcritic.nix { };
}
