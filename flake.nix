{
  description = "TODO";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    luna.url = "github:asicsforthemasses/LunaPnR";
    luna.flake = false; #TODO

    opensta.url = "github:The-OpenROAD-Project/OpenSTA";
    opensta.flake = false;
  };

  outputs = { nixpkgs, ... }@inputs:
  let
    # System types to support.
    supportedSystems = ["x86_64-linux"];
    # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgsFor = nixpkgs.legacyPackages;

    resolveOverlays = first: overlays: with nixpkgs.lib; let
      # Passing inputs here means overlays can be called with the standard signature
      # but still be parametrized with flakes, maintaining composability. 
      overlay' = flip (composeManyExtensions ([ (final: prev: { inherit inputs; }) ] ++ overlays));
      # We don't to expose all of nixpkgs in the resulting attrset (like with .extend()), #TODO why not, or a .pkgs?
      # so we take the fixpoint ourselves
      attrs = fix (overlay' first);
    in builtins.removeAttrs attrs [ "inputs" ]; #TODO I don't like doing it this way but I don't have a better idea how to keep the interface clean.

    # TODO something is happening with argument processing, if I dont add the pkgs argument here it doesnt get passed to the module and breaks
    # applyModuleArgsIfFunction /nix/store/43m6mis3zbnq5q9rw2yklnf6398p1x93-source/flake.nix
    callModule = modPath: {pkgs, ...}@args: import modPath (args // { inherit inputs; });

    mkSystem = system: modules: nixpkgs.lib.nixosSystem { inherit system modules; }; # TODO does the system argument make sense?
  in {
    packages = genSystems (system:
      let attrs = resolveOverlays pkgsFor.${system} [ (import ./nix/overlay.nix) ];
      in attrs // { default = attrs.luna; }
    );
  };
}
