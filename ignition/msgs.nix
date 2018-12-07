{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  version = "1.0.0";
  ign-cmake = callPackage ./cmake.nix {} ;
  ign-math  = callPackage ./math.nix {} ;
in
stdenv.mkDerivation rec {
  pname = "ign-msgs";
  # name = "ignition-msgs1_${version}";
  name = "ignition-msgs_${version}";

  src = fetchFromBitbucket {
    owner = "ignitionrobotics";
    repo = pname;
    rev = name;
    # sha256 = "108si4zs10c6zw0d166wb1xz6iwc10g3xf86arb5177khh9g38dz"; #ignition-msgs1_1.0.0
    sha256 = "1d8va802vhy9lfkxx6sgfxbcwc0ms6h5psyyv8pg856nhkj02vam"; #ignition-msgs_1.0.0
  };

  buildInputs = [ cmake ign-cmake ign-math protobuf ];
  enableParallelBuilding = true;
  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_INCLUDEDIR=include -DENABLE_TESTS_COMPILATION=false" ];

  # prePatch = ''
  #   sed -i -e 's|ign_install_library(.*)|ign_install_library()|' ignition/msgs/CMakeLists.txt
  # '';

  meta = with stdenv.lib; {
    homepage = https://ignitionrobotics.org/libraries/msgs;
    description = "Protobuf messages and functions for robot applications, created for the Gazebo project";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}