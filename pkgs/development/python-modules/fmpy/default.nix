{
  lib,
  stdenv,
  fetchurl,
  buildPythonPackage,
  fetchFromGitHub,
  pythonOlder,
  cmake,
  sundials,
  lapack,
  attrs,
  lark,
  lxml,
  rpclib,
  msgpack,
  numpy,
  scipy,
  pytz,
  dask,
  requests,
  matplotlib,
  pyqtgraph,
  notebook,
  plotly,
  hatchling,
  pyside6,
  jinja2,
  flask,
}:

let
  cvode =
    (sundials.overrideAttrs (prev: {
      # From native/build_cvode.py
      version = "5.3.0";
      src = fetchurl {
        url = "https://github.com/LLNL/sundials/releases/download/v5.3.0/sundials-5.3.0.tar.gz";
        sha256 = "88dff7e11a366853d8afd5de05bf197a8129a804d9d4461fb64297f1ef89bca7";
      };
    })).override
      {
        lapackSupport = false;
        lapack.isILP64 = stdenv.hostPlatform.is64bit;
        blas = lapack;
        kluSupport = false;
        enableCvodes = false;
        enableArkode = false;
        enableIda = false;
        enableIdas = false;
        enableKinsol = false;
      };
in

buildPythonPackage rec {
  pname = "FMPy";
  version = "a126f6d";
  disabled = pythonOlder "3.10";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "CATIA-Systems";
    repo = "FMPy";
    rev = "a126f6da0180abbad656edac1e32c30a81556877";
    fetchSubmodules = true;
    hash = "sha256-m1Upi24dvrqnTAWr6X1vkUMczJBDn0etKbl8H2Dryp0=";
  };

  nativeBuildInputs = [
    cmake
    pyqtgraph
    pyside6
    hatchling
  ];

  propagatedBuildInputs = [
    attrs
    lark
    lxml
    msgpack
    numpy
    scipy
    pytz
    dask
    requests
    matplotlib
    pyqtgraph
    notebook
    plotly
    rpclib
    cvode
    pyside6
    jinja2
    flask
  ];

  dontUseCmakeConfigure = true;
  dontUseCmakeBuildDir = true;

  patches = [ ./0001-pyproject-comment-out-artifacts-not-built.patch ];

  postPatch = ''
    substitute ${./libraries.py} ./src/fmpy/sundials/libraries.py \
        --subst-var-by cvode ${cvode}
  '';

  # Don't run upstream build scripts as they are too specialized.
  # cvode is already built, so we only need to build native binaries.
  preBuild =
    ''
      cmakeFlags="-S native/src -B native/src/build -D CVODE_INSTALL_DIR=${cvode}"
      cmakeConfigurePhase
      cmake --build native/src/build --config Release
    ''
    + lib.optionalString stdenv.isLinux ''
      # The reproduction of build_remoting.py
      #cmakeFlags="-S native/remoting -B remoting/linux64 -D RPCLIB=${rpclib}"
      #cmakeConfigurePhase
      #cmake --build remoting/linux64 --config Release
    '';

  # Some of tests are supposed to be failing in upstream, so we don't use
  # them for package verification at the moment.
  doCheck = false;

  pythonImportsCheck = [
    "fmpy"
    "fmpy.cross_check"
    "fmpy.cswrapper"
    "fmpy.examples"
    "fmpy.fmucontainer"
    "fmpy.logging"
    "fmpy.gui"
    "fmpy.gui.generated"
    "fmpy.ssp"
    "fmpy.sundials"
  ];

  meta = with lib; {
    description = "Simulate Functional Mockup Units (FMUs) in Python";
    homepage = "https://github.com/CATIA-Systems/FMPy";
    license = with licenses; [ bsd2 ];
    maintainers = with maintainers; [
      balodja
      tmplt
    ];
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
    ];
  };
}
