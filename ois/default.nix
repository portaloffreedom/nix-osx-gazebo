{ pkgs ? import <nixpkgs>{} } :
with pkgs;

let
  majorVersion = "1";
  minorVersion = "4";
in

stdenv.mkDerivation rec {
  name = "ois-${version}";
  version = "${majorVersion}.${minorVersion}";

  # fix darwin compilation error by adding this missing thing: 
  # https://developer.apple.com/documentation/appkit/nswindowstylemask/nswindowstylemasktitled?language=objc
  NIX_CFLAGS_COMPILE="-DNSWindowStyleMaskTitled='1<<0' -w";

    src = fetchFromGitHub {
        owner = "wgois";
        repo = "OIS";
        rev = "a22b0642ae0e7ce2b46cf8a53817e1ed65d2484b";
        sha256 = "00cmx544v1q6ji1ba9da2nhsin6d6yw2hm6fjj98f2jjiw3xpyvd";
    };

  buildInputs = [
    cmake
    # autoconf 
    # automake 
    # libtool 
    x11 
    # xproto 
    # libXi 
    # inputproto 
    # libXaw
    # libXmu 
    # libXt
  ];

  nativeBuildInputs = [
    darwin.apple_sdk.frameworks.Carbon
    darwin.apple_sdk.frameworks.Cocoa
    darwin.apple_sdk.frameworks.Kernel
    darwin.cf-private
  ];

  cmakeFlags = [];

  meta = with stdenv.lib; {
    description = "Object-oriented C++ input system";
    maintainers = [ maintainers.raskin ];
    platforms = [ platforms.linux platforms.darwin ];
    license = licenses.zlib;
  };
}