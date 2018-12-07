{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let 
  version = "6.0.0";
  ign-math = callPackage ../ignition/math.nix {} ;
  ign-cmake = callPackage ../ignition/cmake.nix {} ;
in stdenv.mkDerivation rec {
  pname = "sdformat";
  inherit version;
  name = "${pname}-${version}";

  src = fetchurl {
      url = "http://osrf-distributions.s3.amazonaws.com/${pname}/releases/${name}.tar.bz2";
      sha256 = "0kdw62s7r4b5kx255mrg0zi1vyvp34ipiqs0jbwqfb6rx43q1slk";
  };

  NIX_CFLAGS_COMPILE="-w";
  enableParallelBuilding = true;
  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_INCLUDEDIR=include -DENABLE_TESTS_COMPILATION=false" ];

  buildInputs = [
      cmake
      boost
      pkgconfig
      ign-math
      ign-cmake
      ruby
      tinyxml
  ];
  
  meta = {
    platforms = stdenv.lib.platforms.all;
  };
}