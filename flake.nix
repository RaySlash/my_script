{
  description = "raylib examples";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems = {
      url = "github:nix-systems/default";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];

      systems = import inputs.systems;
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          buildDeps = with pkgs; [
          vscodium
            gcc
            raylib
            nil
            nixd
            pkg-config
            ccls
            clang
            coreutils
            bashInteractive
            stdenv.cc.libc_bin
            openlibm
          ];

          mkDevShell = gcc:
            pkgs.mkShell {
              buildInputs = buildDeps;
              shellHook = ''
                export LD_LIBRARY_PATH="${
                  pkgs.lib.makeLibraryPath buildDeps
                }:$LD_LIBRARY_PATH"
                export CFLAGS="-I${pkgs.raylib}/include $CFLAGS"
              '';
            };
        in {
          _module.args.pkgs = import inputs.nixpkgs { inherit system; };

          formatter = pkgs.alejandra;

          packages.default = self'.packages.raylib;

          devShells.default = mkDevShell "raylib";
        };
    };
}
