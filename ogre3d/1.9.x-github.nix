{ pkgs ? import <nixpkgs> {}, withSamples ? false }:
with pkgs;

let 
  ois = callPackage ../ois {};
  ditto = writeScriptBin "ditto" ''
  #!${stdenv.shell}
  /usr/bin/ditto "$@"
  '';
in stdenv.mkDerivation rec {
  pname = "ogre";
  version = "1.9.1";
  name = "${pname}-${version}";
  NIX_CFLAGS_COMPILE="-w";


  src = fetchFromGitHub {
    owner = "OGRECave";
    repo = "ogre";
    rev = "v${version}";
    sha256 = "11lfgzqaps3728dswrq3cbwk7aicigyz08q4hfyy6ikc6m35r4wg";
  };

  cmakeFlags = [ "-DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF"
                 "-DOGRE_BUILD_SAMPLES=${toString withSamples}" ]
    ++ map (x: "-DOGRE_BUILD_PLUGIN_${x}=on")
           ([ "BSP" "OCTREE" "PCZ" "PFX" ])# ++ lib.optional withNvidiaCg "CG")
    ++ map (x: "-DOGRE_BUILD_RENDERSYSTEM_${x}=on") [ "GL" ];

  prePatch = ''
    sed -i -e "s|-framework OpenGL|-framework OpenGL -framework AGL|" RenderSystems/GL/CMakeLists.txt
  '';

  enableParallelBuilding = true;

  buildInputs = [
        SDL2
        cmake 
        libGLU_combined
        freetype
        freeimage
        zziplib
        freeglut 
        libpng 
        # boost 
        poco
        ois
        tinyxml
        tbb
        pkgconfig
   ]; #++ lib.optional withNvidiaCg nvidia_cg_toolkit;
  nativeBuildInputs = if stdenv.isDarwin then [ 
        ditto
        darwin.apple_sdk.frameworks.Cocoa
        darwin.apple_sdk.frameworks.AGL
        darwin.cf-private
    ] else [
        x11
        libICE
        libSM 
        libX11 
        libXaw 
        libXmu 
        libXt 
        libXrandr
        libXrender
        libXxf86vm 
        randrproto
        renderproto 
        xf86vidmodeproto 
        xproto 
    ];
  meta = {
    description = "A 3D engine";
    homepage = https://www.ogre3d.org/;
    maintainers = [ stdenv.lib.maintainers.raskin ];
    platforms = [ stdenv.lib.platforms.linux stdenv.lib.platforms.darwin ];
    license = stdenv.lib.licenses.mit;
  };
}