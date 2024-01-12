{
  description = "joblog program";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay.url = "github:oxalica/rust-overlay";
    systems = {
      url = "github:nix-systems/default";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
      ];

      systems = import inputs.systems;
      perSystem = { config, self', inputs', pkgs, system, ... }:
      let
        rust-toolchain = (pkgs.rust-bin.fromRustupToolchainFile ./toolchain.toml);

        buildDeps = with pkgs; [
          (lib.getLib gcc-unwrapped)
          pkg-config
          clang
        ] ++ ( with pkgsCross; [ mingw32.buildPackages.gcc mingwW64.buildPackages.gcc ]);

        mkPackage = rust-toolchain: pkgs.rustPlatform.buildRustPackage {
          name = "joblog";
          version = "0.1";
          src = ./.;
          buildInputs = buildDeps;
          nativeBuildInputs = buildDeps;
          cargoLock.lockFile = ./Cargo.lock;
          meta = {
            description = "A Rusty program to record Joblog with timestamps in csv";
            license = "gpl3Plus";
            mainprogram = "joblog";
          };
        };

        mkDevShell = rust-toolchain: pkgs.mkShell {
          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath buildDeps}:$LD_LIBRARY_PATH"
            export PATH="$PATH:/home/$USER/.cargo/bin"
            export CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS="-L native=${pkgs.pkgsCross.mingwW64.buildPackages.gcc}/lib:${pkgs.pkgsCross.mingw32.buildPackages.gcc}/lib"
          '';
          packages = buildDeps ++ [ rust-toolchain ];
        };
    in
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ (import inputs.rust-overlay) ];
      };

      formatter = pkgs.alejandra;

      packages.default = self'.packages.joblog;
      packages.joblog = (mkPackage "joblog");

      devShells.default = self'.devShells.msrv;
      devShells.msrv = (mkDevShell rust-toolchain);
      devShells.stable = (mkDevShell pkgs.rust-bin.stable.latest.default);
      devShells.nightly = (mkDevShell (pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default)));
    };
  };
}
