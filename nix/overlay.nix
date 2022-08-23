final: prev:
(with builtins; seq ((hasAttr "inputs" prev) || throw "If you are calling this directly, make sure the overlays have an `inputs` attribute conforming to the flakes interface."))
{
  luna = prev.libsForQt5.callPackage ({ wrapQtAppsHook, qtbase, qttools, mkDerivation, python38 }: mkDerivation {
    pname = "luna";
    version =
      let
        inherit (prev.inputs.luna) lastModifiedDate;
        year = builtins.substring 0 4 lastModifiedDate;
        month = builtins.substring 4 2 lastModifiedDate;
        day = builtins.substring 6 2 lastModifiedDate;
      in
        "unstable-${year}-${month}-${day}";

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
    '';

    # broken as tools/doctool is used before it is being built
    enableParallelBuilding = false;
  }) {};
}
