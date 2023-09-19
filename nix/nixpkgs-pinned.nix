# Provide almost the same arguments as the actual nixpkgs.
# This allows us to further configure this nixpkgs instantiation in places where we need it.
# In particular, `stack` needs this to be a function.
{ overlays ? [] # additional overlays
, config ? {} # Imported configuration
, use_overlays ? true # Option to disable overlays, to get packages from purely nixpkgs
}:
# Provides our instantiation of nixpkgs with all overlays and extra tooling
# that we pull in from other repositories.
# This expression is what all places where we need a concrete instantiation of nixpkgs should use.
let
  sources = import ./sources.nix;

  # Use no overlays when disabled. This way it is possible to use e.g. Cachix from nixpkgs, without
  # it being affected by overlays.
  used_overlays = if use_overlays then
      [
        (import ./overlay.nix)
      ] ++ overlays
    else
      [];

  nixpkgs = import sources.nixpkgs {
    overlays = used_overlays;
    config = {
      imports = [ config ];
      allowUnfree = true;
    };
  };
in
  nixpkgs
