{ stdenv, idris, postgresql }:
stdenv.mkDerivation {
    name = "dbcritic";

    src = stdenv.lib.cleanSource ./.;
    buildInputs = [ idris postgresql ];

    phases = [ "unpackPhase" "buildPhase"
               "installPhase" "fixupPhase" ];
    installPhase = ''
        mkdir --parents "$out/bin"
        mv dbcritic "$out/bin"
    '';
}
