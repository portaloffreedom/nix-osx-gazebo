{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  version = "0.6.1";
in
stdenv.mkDerivation rec {
  pname = "ign-cmake";
  name = "ignition-cmake_${version}";

  src = fetchFromBitbucket {
    owner = "ignitionrobotics";
    repo = pname;
    rev = name;
    sha256 = "053rvynfr1i9whlr9bzxcrnp487j5p17q4w4k05l4asp9vba7yrs";
  };

  buildInputs = [ cmake ];
  enableParallelBuilding = true;
  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_INCLUDEDIR=include -DENABLE_TESTS_COMPILATION=false" ];

  meta = with stdenv.lib; {
    platforms = platforms.all;
  };
}