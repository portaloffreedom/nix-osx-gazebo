{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  version = "4.0.0";
  ign-math = callPackage ./cmake.nix {} ;
in
stdenv.mkDerivation rec {
  pname = "ign-math";
  name = "ignition-math4_${version}";

  src = fetchFromBitbucket {
    owner = "ignitionrobotics";
    repo = pname;
    rev = name;
    sha256 = "12jbfp5jh71ryippvbxagxq4xdkxyq0idjvk3vpyz6gnd70q6d1a";
  };

  buildInputs = [ cmake ign-math ];
  enableParallelBuilding = true;
  cmakeFlags = [ "-DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_INSTALL_INCLUDEDIR=include -DENABLE_TESTS_COMPILATION=false" ];

  meta = with stdenv.lib; {
    homepage = https://ignitionrobotics.org/libraries/math;
    description = "Math library by Ingition Robotics, created for the Gazebo project";
    license = licenses.asl20;
    maintainers = with maintainers; [ pxc ];
    platforms = platforms.all;
  };
}