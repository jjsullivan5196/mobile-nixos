{ stdenv }:

stdenv.mkDerivation rec {
  name = "crust-firmware-blob";
  src = ./.;

  installPhase = "mkdir $out; cp -v scp.bin $out";
}
