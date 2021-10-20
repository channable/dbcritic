{ stdenv, lib, idris, postgresql }:
stdenv.mkDerivation {
    name = "dbcritic";

    src = lib.cleanSource ./.;
    buildInputs = [ idris postgresql ];

    phases = [ "unpackPhase" "buildPhase"
               "installPhase" "fixupPhase" ];
    installPhase = ''
        mkdir --parents "$out/bin"
        mv dbcritic-bin "$out/bin/dbcritic"
    '';
}
