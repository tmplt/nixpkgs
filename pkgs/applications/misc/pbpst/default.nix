{ llvmPackages, stdenv, fetchFromGitHub
, python36Packages, which, pkgconfig, curl, git, gettext, jansson

# Optional overrides
, maxFileSize ? 64 # in MB
, provider ? "https://ptpb.pw/"
}:

llvmPackages.stdenv.mkDerivation rec {
  version = "unstable-2018-12-02";
  name = "pbpst-${version}";

  src = fetchFromGitHub {
    owner = "HalosGhost";
    repo = "pbpst";
    rev = "572df1a5009b09fe627330f0c92ddc7631eeb7ce";
    sha256 = "11sldlldw94qipcry7r4bz0ryx40w8ls4x5lg5w24viy7q6cc4p1";
  };

  nativeBuildInputs = [
    python36Packages.sphinx
    which
    pkgconfig
    curl
    git
    gettext
  ];
  buildInputs = [ curl jansson ];

  patchPhase = ''
    patchShebangs ./configure

    # Remove dependency check
    sed -e '131d' -i ./configure
  '';

  configureFlags = [
    "--file-max=${toString (maxFileSize * 1024 * 1024)}" # convert to bytes
    "--provider=${provider}"
  ];

  meta = with stdenv.lib; {
    description = "A command-line libcurl C client for pb deployments";
    inherit (src.meta) homepage;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ tmplt ];
  };
}
