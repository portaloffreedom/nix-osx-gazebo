{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  inherit stdenv cmake tbb qwt6;
  ogre = callPackage ../ogre3d/1.9.x.nix {};
  ign-cmake     = callPackage ../ignition/cmake.nix {} ;
  ign-math      = callPackage ../ignition/math.nix {} ;
  ign-msgs      = callPackage ../ignition/msgs.nix {} ;
  ign-transport = callPackage ../ignition/transport4.nix {} ;
  sdformat = callPackage ../sdformat {};
  gazebo = callPackage ../gazebo9/gazebo.nix {};
in stdenv.mkDerivation rec {
  name = "revolve";

  src = fetchFromGitHub {
    owner = "ci-group";
    repo = "revolve";
    rev = "gazebo9";
    sha256 = "0dxqdglzpl9zqx69pkfiv012m3mnd6b834xsakgnlhp1vmfga4k2";
  };

  cmakeFlags = [ ];
  enableParallelBuilding = true;
  DYLD_LIBRARY_PATH="${tbb}/lib:${qwt6}/lib";
  QT_PLUGIN_PATH="${qt5.qtbase.bin}/${qt5.qtbase.qtPluginPrefix}";

  buildInputs = [
    gcc
    boost
    bullet
    cmake
    cppzmq
    freeimage
    gazebo
    gsl
    ign-cmake
    ign-math
    ign-msgs
    ign-transport
    libossp_uuid
    ogre
    poco
    pkgconfig
    protobuf
    sdformat
    tbb
    zeromq # ign transport dependency
  ];

  meta = {
  description = "Robot evolution framework for http://evosphere.eu/";
  homepage = https://github.com/ci-group/revolve;
  platforms = stdenv.lib.platforms.all;
  license = stdenv.lib.licenses.apache;
  };
}