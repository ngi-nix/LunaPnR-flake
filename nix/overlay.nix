final: prev:
(with builtins; seq ((hasAttr "inputs" prev) || throw "If you are calling this directly, make sure the overlays have an `inputs` attribute conforming to the flakes interface."))
({
  #TODO specified as _At least_ 512
  luna = prev.libsForQt512.callPackage ({ wrapQtAppsHook, qtbase, qttools, mkDerivation, python38 }: mkDerivation {
    pname = "luna";
    version = "unstable-2021-10-19";

    src = final.inputs.luna;

    buildInputs = with prev; [ qtbase qttools eigen boost ];
    propagatedBuildInputs = [ python38 ];
    nativeBuildInputs = with prev; [ wrapQtAppsHook cmake ninja];
    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Debug"
      # "-DUseCPPCHECK=ON"
      # "-DUseCLANGTIDY=ON"
      ];

    patchPhase = ''
      substituteInPlace CMakeLists.txt --replace 'include(Packing)' '''
      substituteInPlace CMakeLists.txt --replace 'enable_testing()' '''
      substituteInPlace test/core/CMakeLists.txt --replace 'enable_testing()' '''
      substituteInPlace CMakeLists.txt --replace 'add_subdirectory(test)' '''
      substituteInPlace CMakeLists.txt --replace 'DESTINATION ''${LUNA_INSTALL_PREFIX}/bin)' "DESTINATION $out/bin)"
      '';

    postBuild = ''
      mkdir -p $out/bin
      '';
    }) {};
  })
