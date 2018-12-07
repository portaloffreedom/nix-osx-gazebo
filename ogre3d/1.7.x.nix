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
  version = "1.7.4";
  name = "${pname}-${version}";
  NIX_CFLAGS_COMPILE="-w";


  src = fetchurl {
    url = "https://downloads.sourceforge.net/project/ogre/ogre/1.7/ogre_src_v1-7-4.tar.bz2";
    sha256 = "afa475803d9e6980ddf3641dceaa53fcfbd348506ed67893c306766c166a4882";
  };

  cmakeFlags = [ "-DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF"
                 "-DOGRE_BUILD_SAMPLES=${toString withSamples}" ]
    ++ map (x: "-DOGRE_BUILD_PLUGIN_${x}=on")
           ([ "BSP" "OCTREE" "PCZ" "PFX" ])# ++ lib.optional withNvidiaCg "CG")
    ++ map (x: "-DOGRE_BUILD_RENDERSYSTEM_${x}=on") [ "GL" ];

  prePatch = ''
    sed -i -e "s|-framework OpenGL|-framework OpenGL  -framework AGL|" RenderSystems/GL/CMakeLists.txt
    # sed -i -e "s/CMAKE_FORCE_C_COMPILER(gcc-4.0 GNU)//" CMakeLists.txt
    # sed -i -e "s/CMAKE_FORCE_CXX_COMPILER(gcc-4.0 GNU)//" CMakeLists.txt
  '';

  patches = [
    (fetchurl {
      url = "https://gist.github.com/wjwwood/4237236/raw/e357f1b9fa8b26d02ed84f411d5b5eb7446c68c5/pkg_config_fix.patch";
      sha256 = "a2296a0e505906a09add6534fcc6f60ce598bb56b7fd422953cf92dbfee3ac00";
    })
    (fetchurl {
      url = "https://gist.github.com/wjwwood/4237236/raw/57cb907304433cc0bb83fd332ff98a5789102b00/prevent_framework_apple.patch";
      sha256 = "1416fd5dc44f5e219bf7a675888aad53c5f9a4f0596ff35ccdb7ef2a7f7d60a9";
    })
    (fetchurl {
      url = "https://gist.github.com/wjwwood/4237236/raw/31ae53cefdb693cb2fb81333178163a29f8cf7ca/osx_isystem.patch";
      sha256 = "a9b010ac15a662a58e13e425d9dde64c2edb04f06650394e8c2b12e451120a4e";
    })
    (fetchurl {
      url = "https://gist.github.com/wjwwood/4237236/raw/9c7df6689da4e0b358429692f6615f2707469f45/osx_linking.patch";
      sha256 = "3d971465cf251eaea6d39538b92e9f3a0fbaf7fe3f0e8add10aeadde9f12c338";
    })
    (fetchurl {
      url = "https://gist.github.com/wjwwood/4237236/raw/d667813d5ee1e712e0ea8cc99df9a85da6141b1e/replace_pbxcp_with_ditto.patch";
      sha256 = "990abb97fd1a5410a8a557915c8f16d2507133973d6c073acc59b8d0696f8c4d";
    })
    (fetchurl {
      url = "https://gist.github.com/wjwwood/5672104/raw/bf69b4528b3090ad99a760029beb75b7aeb11248/fix_boost_linking.patch";
      sha256 = "6962171371f55ad6cc4c6310078c6f563ddc0ae25152b77e4da24d2d8ce2eecb";
    })
    (fetchurl {
      url = "https://gist.github.com/hgaiser/7346167/raw/3167c2fde153618e55b37f857ef4a90cc54ed2a3/ogre.patch";
      sha256 = "f81ddf3c6974857311816b2f2c2f974c6365d154f9273bf7c5b5fc37867bb292";
    })
    (fetchurl {
      url = "https://gist.github.com/scpeters/b9034c613189426c2d6a/raw/b74a4c1fb795a69b42d1189dc2a35fac3b975959/ogre_agl.diff";
      sha256 = "010413134085b2849491541f887e6fdc63bf87824689411dd9a9d3d06664b7f2";
    })
    (fetchurl {
      url = "https://bitbucket.org/scpeters/ogre/commits/78331c592397878ab3377b5f9b55086aca7a63e5/raw";
      sha256 = "baf485a26993fa9c290701779bb78cc778f2c6d4f4aa2a26e85c6949f8ed4333";
    })
  ];

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
        boost 
        poco
        ois
        tinyxml
        tbb
        pkgconfig
        x11
        xorg.libXaw
   ]; #++ lib.optional withNvidiaCg nvidia_cg_toolkit;
  nativeBuildInputs = if stdenv.isDarwin then [ 
        ditto
        darwin.apple_sdk.frameworks.Cocoa
        darwin.apple_sdk.frameworks.AGL
        darwin.cf-private
    ] else [
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