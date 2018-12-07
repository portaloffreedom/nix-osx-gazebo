{ pkgs ? import <nixpkgs> {}, withSamples ? false, withDocs ? false }:
with pkgs;

let 
  ois = callPackage ../ois {};
  ditto = writeScriptBin "ditto" ''
  #!${stdenv.shell}
  /usr/bin/ditto "$@"
  '';
in stdenv.mkDerivation rec {
  pname = "ogre";
  version = "1.9-20160714-108ab0bcc69603dba32c0ffd4bbbc39051f421c9";
  name = "${pname}-${version}";
  NIX_CFLAGS_COMPILE="-w";

  src = fetchurl { 
    url = "https://bitbucket.org/sinbad/ogre/get/108ab0bcc69603dba32c0ffd4bbbc39051f421c9.tar.bz2";
    sha256 = "3ca667b959905b290d782d7f0808e35d075c85db809d3239018e4e10e89b1721";
  };

  cmakeFlags = [ "-DCMAKE_OSX_ARCHITECTURES='x86_64'"
      "-DOGRE_BUILD_LIBS_AS_FRAMEWORKS=OFF"
      "-DOGRE_FULL_RPATH:BOOL=FALSE"
      "-DOGRE_BUILD_DOCS:BOOL=${toString withDocs}" #TODO verify this works
      "-DOGRE_INSTALL_DOCS:BOOL=${toString withDocs}" 
      "-DOGRE_BUILD_SAMPLES:BOOL=${toString withSamples}" #TODO verify this works
      "-DOGRE_INSTALL_SAMPLES:BOOL=${toString withSamples}"
      "-DOGRE_INSTALL_SAMPLES_SOURCE:BOOL=${toString withSamples}" ]
    ++ map (x: "-DOGRE_BUILD_PLUGIN_${x}=on")
           ([ "BSP" "OCTREE" "PCZ" "PFX" ])# ++ lib.optional withNvidiaCg "CG")
    ++ map (x: "-DOGRE_BUILD_RENDERSYSTEM_${x}=on") [ "GL" ];

  # prePatch = ''
  #   sed -i -e "s|-framework OpenGL|-framework OpenGL  -framework AGL|" RenderSystems/GL/CMakeLists.txt
  # '';

  patches = [
  (fetchurl {
    url = "https://gist.github.com/NikolausDemmel/2b11d1b49b35cd27a102/raw/bf4a4d16020821218f73db0d56aa111ab2fde679/fix-1.9-HEAD.diff";
    sha256 = "15ecd1f12266918650ea789e2f96da4b0ef1a96076d7a671d3c56d98e2459712";
  })
  (fetchurl {
    # retain osx cocoa window
    url = "https://gist.githubusercontent.com/NikolausDemmel/927bd7bb3f14c1788599/raw/c9a5ba88b758e80d3f46511629c4e8026b92c462/ogre1.9.patch";
    sha256 = "e82d842138f7f5ff4637ed313d1140c3b868c8425d4cdba7a71e0a9d7f7e0fd6";
  })
  (fetchurl {
    # disable building samples if ois is not available
    url = "https://gist.githubusercontent.com/iche033/68349eebfc436e484b70e6e3508ae27b/raw/d96227cd79ed1d63f051689a18c95a1c174a4efa/ogre-1.9-ois.patch";
    sha256 = "7ad630740217ccb9f48898507e9c6713dcd37a677a9669cdc16ef39afbf68826";
  })
  (fetchurl {
    # link against AGL framework
    url = "https://gist.githubusercontent.com/iche033/b73766fac9ab3d628a79b5ed986677cd/raw/878d0902704c7fb51511163052c95294361f1dbe/ogre-1.9-agl.patch";
    sha256 = "8122c7eb52faae0fdedb70278d24e2581c88d1181de4d6e94d27bc1b3e596181";
  })
  (fetchurl {
    # backport cocoa window fix to support contents scaling factor (for retina displays)
    url = "https://gist.githubusercontent.com/iche033/e0080a592c890cc9a4fce31f6863a5ed/raw/875ae8ad1d9f0eaa271fd44eab8e0979bac74119/ogre-1.9-cocoa_window_scale.patch";
    sha256 = "c20c288530ea4d11b37f9c8b30cb43c89722c85eac0af3b6520cd89c37014e5b";
  })
  (fetchurl {
    # add libc++ flag
    url = "https://gist.githubusercontent.com/iche033/e2b152d9df080b21f71ba3b65aa39922/raw/5397fa149c7570c17f2d78421d44b12dfa175387/ogre-1.9-cxx_flags.patch";
    sha256 = "7dc77285029c34b4a6adb52b0d4b9c40578526a5e9764d0a7091c6a4cb63fa78";
  })
  (fetchurl {
    # fix FindOGRE.cmake for non-framework builds
    url = "https://gist.githubusercontent.com/iche033/2b5e2ba31436881f1db29f9b60c7a5b2/raw/b6ab953ebd82127ad1177744f367a36e059312a9/ogre-1.9-findogre.patch";
    sha256 = "7ca6f549fbdff7b7fc334f06da4547e071ec0e3f2733897fc6ef0d2bfa1716a3";
  })
  (fetchurl {
    # fix for boost 1.65
    url = "https://bitbucket.org/sinbad/ogre/commits/0cd739f7551d0aad3329abb42d981e970e074fa7/raw";
    sha256 = "cb22b8703f36596efa13618085b2d1a59522d04386cf7eb6eca42a99d0abe83d";
  })
  (fetchurl {
    # fix for boost 1.67
    url = "https://bitbucket.org/sinbad/ogre/commits/16a75ea693e65fed3af943b4b2bfaa7e6c8219b1/raw";
    sha256 = "ffad5129caf3344fb408d6af3c8076bb4e97becdcd6d08302db469694a596616";
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