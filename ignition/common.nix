{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  version = "1.1.1";
in
stdenv.mkDerivation rec {
  pname = "ign-common";
  name = "ignition-common_${version}";

  src = fetchFromBitbucket {
    owner = "ignitionrobotics";
    repo = pname;
    rev = "4d7ed1df80b0b62e729f3a1551bae8359dc29436";
    sha256 = "0w124gi7xckgfvhcshgadjcmyphbxjfj4qm2ifyq74h9z08q6bwh";
  };

  buildInputs = [ cmake ];
  enableParallelBuilding = true;
  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_INCLUDEDIR=include -DENABLE_TESTS_COMPILATION=false" ];

  meta = with stdenv.lib; {
    platforms = platforms.all;
  };
}