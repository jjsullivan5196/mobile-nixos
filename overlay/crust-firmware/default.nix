{ stdenv, fetchFromGitHub
, or1k-elf }:

stdenv.mkDerivation rec {
  pname = "crust-firmware";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "crust-firmware";
    repo = "crust";
    rev = "v${version}";
    sha256 = "0wnl8mmkka81ad289xyx29bjmp120hvqynf3jj1wvvxvysqdc1gs";
  };

  nativeBuildInputs = [
    or1k-elf
    flex
    yacc
  ];

  buildPhase = ''
    export LEX=${flex}/bin/flex
    export YACC=${yacc}/bin/yacc
    export CROSS_COMPILE=${or1k-elf}/bin/or1k-elf-

    make pinephone_defconfig
    make scp
  '';

  installPhase = ''
    mkdir -p $out/
    cp -v build/scp/scp.bin $out/
  '';
}
