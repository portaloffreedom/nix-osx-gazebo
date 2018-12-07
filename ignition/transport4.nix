{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  version = "4.0.0";
  ign-cmake = callPackage ./cmake.nix {} ;
  ign-math = callPackage ./math.nix {} ;
  ign-msgs = callPackage ./msgs.nix {} ;
in
stdenv.mkDerivation rec {
  pname = "ign-transport";
  name = "ignition-transport4_${version}";

  src = fetchFromBitbucket {
    owner = "ignitionrobotics";
    repo = pname;
    rev = name;
    sha256 = "057bvhh9ibjl79jz9a5pq2cd6kvbynqnhm2kf50lrdm2my40am51";
  };

  buildInputs = [ cmake 
    pkgconfig
    ign-cmake 
    ign-math 
    ign-msgs 
    protobuf
    libossp_uuid
    zeromq
    cppzmq
  ];
  enableParallelBuilding = true;
  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_INCLUDEDIR=include -DENABLE_TESTS_COMPILATION=false" ];

  meta = with stdenv.lib; {
    homepage = https://ignitionrobotics.org/libraries/transport;
    description = "Protobuf messages and functions for robot applications, created for the Gazebo project";
    license = licenses.asl20;
    platforms = platforms.all;
  };
}