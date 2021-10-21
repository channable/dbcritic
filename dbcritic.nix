{ stdenv, lib, idris, postgresql }:
stdenv.mkDerivation {
    name = "dbcritic";

    # Remove files that don't affect the final build.
    # Keep only:
    #  - The Makefile
    #  - Any file ending in `.idr`
    #  - The directories containing source (i.e. not `.git`, `.semaphore` and `nix`)
    src = lib.cleanSourceWith {
      src = ./.;
      filter = path: _type:
        lib.strings.hasSuffix "Makefile" path
        || lib.strings.hasSuffix ".idr" path
        || (
          lib.pathIsDirectory path
          && !builtins.elem (baseNameOf path) ["nix" ".semaphore" ".git"]
        );
    };

    buildInputs = [ idris postgresql ];

    phases = [ "unpackPhase" "buildPhase"
               "installPhase" "fixupPhase" ];
    installPhase = ''
        mkdir --parents "$out/bin"
        mv dbcritic-bin "$out/bin/dbcritic"
    '';
}
