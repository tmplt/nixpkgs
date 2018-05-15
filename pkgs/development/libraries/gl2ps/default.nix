{ fetchurl, stdenv, libpng, libGLU_combined, texlive, cmake }:

stdenv.mkDerivation rec {
  name = "gl2ps-${version}";
  version = "1.4.0";

  src = fetchurl {
    url = "http://geuz.org/gl2ps/src/gl2ps-1.4.0.tgz";
    sha256 = "03cb5e6dfcd87183f3b9ba3b22f04cd155096af81e52988cc37d8d8efe6cf1e2";
  };

  buildInputs = [ libpng libGLU_combined texlive.combined.scheme-basic ];

  nativeBuildInputs = [ cmake ];

  meta = with stdenv.lib; {
    homepage = http://geuz.org/gl2ps/;
    license = licenses.bsd3;
    description = "An OpenGL to PostScript printing library";
    maintainers = with maintainers; [ tmplt ];
    platforms = platforms.linux;
  };
}
