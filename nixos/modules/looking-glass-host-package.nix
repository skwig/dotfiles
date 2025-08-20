{
  pkgs,
  stdenv,
  fetchFromGitHub,
  ...
}:

stdenv.mkDerivation {
  pname = "looking-glass-host";
  version = "B7";

  src = fetchFromGitHub {
    owner = "gnif";
    repo = "LookingGlass";
    rev = "B7";
    hash = "sha256-I84oVLeS63mnR19vTalgvLvA5RzCPTXV+tSsw+ImDwQ=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.pkg-config
  ];

  buildInputs = [
    pkgs.glib
    pkgs.pipewire
    pkgs.libbfd
    pkgs.xorg.libxcb
  ];

  cmakeFlags = [
    "-DOPTIMIZE_FOR_NATIVE=OFF"
    "-DUSE_XCB=OFF"
  ];

  postUnpack = ''
    echo "B7" > source/VERSION
    export sourceRoot="source/host"
  '';

  patchPhase = ''
    substituteInPlace CMakeLists.txt \
      --replace "-Werror" ""
  '';

  postInstall = ''
    mkdir -p $out/share/pixmaps
    cp $src/resources/lg-logo.png $out/share/pixmaps
  '';
}
