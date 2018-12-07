{ pkgs ? import <nixpkgs> {} }:
with pkgs;

let 
  version = "3.1.1";
  pname = "sdformat";
  name = "${pname}-${version}";
in stdenv.mkDerivation rec {

  src = fetchurl {
      url = "http://osrf-distributions.s3.amazonaws.com/${pname}/releases/${name}.tar.bz2";
      sha256 = "0msnhxmhqx6xnq7hdmcndkg1rxmrdrqzxg953zgdcggxbyh69szz";
  };

  NIX_CFLAGS_COMPILE="-w";
  enableParallelBuilding = true;

  buildInputs = [
  ];

  meta = {
    description = "A 3D engine";
    homepage = https://www.ogre3d.org/;
    maintainers = [ stdenv.lib.maintainers.raskin ];
    platforms = [ stdenv.lib.platforms.linux stdenv.lib.platforms.darwin ];
    license = stdenv.lib.licenses.mit;
  };
}