{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let 
  inherit stdenv fetchurl cmake protobuf boost freeimage pkgconfig tbb curl;
  version = "9.5.0";
  ogre = callPackage ../ogre3d/1.9.x.nix {};
  ign-cmake     = callPackage ../ignition/cmake.nix {} ;
  ign-math      = callPackage ../ignition/math.nix {} ;
  ign-msgs      = callPackage ../ignition/msgs.nix {} ;
  ign-transport = callPackage ../ignition/transport4.nix {} ;
  sdformat = callPackage ../sdformat {};
in stdenv.mkDerivation rec {
  pname = "gazebo";
  inherit version;
  name = "${pname}-${version}";

  src = fetchurl {
    url = "http://gazebosim.org/distributions/gazebo/releases/gazebo-9.5.0.tar.bz2";
    sha256 = "f827167a46c47fccf8013accbffb7d1e5327124ef5579ea7cb44ade4d96b4fbb";
  };

  NIX_CFLAGS_COMPILE="-w";
  cmakeFlags = [ 
    "-DENABLE_SSE4=True"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
  ];
  enableParallelBuilding = true;

  prePatch = ''
    sed -i -e 's|#include <qwt/qwt|#include <qwt|' gazebo/gui/plot/qwt_gazebo.h
  '';

  buildInputs = [ 
    boost
    bullet
    cmake
    curl
    freeimage
    gdal # optional if you want terrain generation
    ign-cmake
    ign-math
    ign-msgs
    ign-transport
    libtar
    qwt6
    ogre
    pkgconfig
    poco
    protobuf
    qt59.qtbase
    sdformat
    tbb
    tinyxml
    tinyxml-2
    zeromq # ign transport dependency
    libossp_uuid
    cppzmq
  ];
  
  nativeBuildInputs = if stdenv.isDarwin then [
    darwin.apple_sdk.frameworks.OpenAL
  ] else [
  ];

  meta = {
    description = "Robot Simulator";
    homepage = http://gazebosim.org/;
    platforms = [ stdenv.lib.platforms.linux stdenv.lib.platforms.darwin ];
    license = stdenv.lib.licenses.apache;
  };
}