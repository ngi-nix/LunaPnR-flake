final: prev:
let
  inputVersion = input:
    let
      inherit (input) lastModifiedDate;
      year = builtins.substring 0 4 lastModifiedDate;
      month = builtins.substring 4 2 lastModifiedDate;
      day = builtins.substring 6 2 lastModifiedDate;
    in
      "unstable-${year}-${month}-${day}";
in (
with builtins; seq ((hasAttr "inputs" prev) || throw "If you are calling this directly, make sure the overlays have an `inputs` attribute conforming to the flakes interface."))
{
    luna = prev.libsForQt5.callPackage ({ wrapQtAppsHook, qtbase, qttools, mkDerivation, python38 }: mkDerivation {
    pname = "luna";
    version = inputVersion final.inputs.luna;

    src = final.inputs.luna;

    buildInputs = with prev; [ qtbase qttools eigen boost ];
    propagatedBuildInputs = [ python38 ];
    nativeBuildInputs = with prev; [ wrapQtAppsHook cmake ninja ];

    patchPhase = ''
      substituteInPlace CMakeLists.txt \
        --replace 'enable_testing()' ''' \
        --replace 'add_subdirectory(test)' ''' \
        --replace 'DESTINATION ''${LUNA_INSTALL_PREFIX}/bin)' "DESTINATION $out/bin)"
      substituteInPlace test/core/CMakeLists.txt \
        --replace 'enable_testing()' '''
      substituteInPlace gui/src/mainwindow.cpp \
        --replace 'settings.value("opensta_location", "/usr/local/bin/sta").toString()' 'QString("${final.opensta}/bin/sta")'
    '';

    # broken as tools/doctool is used before it is being built
    enableParallelBuilding = false;
  }) {};

  opensta = prev.callPackage ({ stdenv, cmake }: stdenv.mkDerivation {
    pname = "opensta";
    version = inputVersion final.inputs.opensta;

    src = final.inputs.opensta;

    nativeBuildInputs = with prev; [ cmake flex bison swig ];
    buildInputs = with prev; [ zlib tcl ];
  }) {};
}
