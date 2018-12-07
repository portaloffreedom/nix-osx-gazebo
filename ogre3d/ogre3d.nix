{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let
  inherit stdenv fetchurl cmake unzip SDL2 freeimage;
  version = "1.11.2";
  # version = "1.8.1";
  ditto = writeScriptBin "ditto" ''
  #!${stdenv.shell}
  /usr/bin/ditto "$@"
  '';
  unpackSource = writeScriptBin "unpackSource" ''
  #!${stdenv.shell}
  unzip "$@"
  # tar xvaf "$@"
  '';
  ois = callPackage ../ois {};
in
{
  ogre3d = stdenv.mkDerivation rec {
    inherit version;
    MAKEFLAGS = "-j4";
    NIX_CFLAGS_COMPILE="-DDEPLOYMENT_RUNTIME_SWIFT=0";
    NIX_LDFLAGS="-lobjc -lAGL";
    enableParallelBuilding = true;
    name = "ogre3d-${version}";
    folder_name = "ogre-${version}";
    # folder_name = "ogre_src_v1-8-1";
    buildInputs = [ 
      unpackSource
      libGLU_combined
      zziplib 
      freeglut 
      libpng 
      boost
      ois
      x11 # darwin.X11AndOpenGL
      # openexr # error "ImathInt64.h" header not found
      cmake
      unzip
      freetype
      SDL2
      freeimage
      pkgconfig
    ];
    nativeBuildInputs = if stdenv.isDarwin then [ 
      ditto
      # swift
      # darwin.apple_sdk.frameworks.Foundation
      # darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.CoreGraphics
      # darwin.apple_sdk.frameworks.IOKit
      darwin.apple_sdk.frameworks.AGL
      # darwin.apple_sdk.frameworks.Carbon
      darwin.apple_sdk.frameworks.Cocoa
      # darwin.xcode 
      # darwin.objc4 
      # darwin.CoreSymbolication 
      # darwin.opencfliteo
      # darwin.CF 
      # darwin.apple_sdk.sdk
      darwin.cf-private
    ] else [ #linux
      libXt
      randrproto
      libXrandr
      libXaw
      xproto
      libX11
      libXmu
      libSM
      libXxf86vm
      xf86vidmodeproto
      libICE
      renderproto
      libXrender
      nvidia_cg_toolkit
      openexr
    ];
    builder = ./builder.sh;
    src = fetchurl {
      url = "https://github.com/OGRECave/ogre/archive/v${version}.zip";
      sha256 = "0x2mch8b349rcpqqffswysffisx7gkg0vl681mvqkahx118n4j1h";
      # url = "https://netcologne.dl.sourceforge.net/project/ogre/ogre/1.8/${version}/${folder_name}.tar.bz2";
      # sha256 = "1avadx87sdfdk8165wlffnd5dzks694dcdnkg3ijap966k4qm46s";
    };
  };
}