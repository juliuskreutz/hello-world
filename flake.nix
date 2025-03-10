{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    {
      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.hello-world;
        in
        {
          options.programs.hello-world = {
            enable = lib.mkEnableOption "hello-world";
          };

          config = lib.mkIf cfg.enable {
            environment.systemPackages = [
              self.packages.${pkgs.system}.hello-world
            ];
          };
        };
      nixosModules.hello-world = self.nixosModules.default;
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells.default =
          with pkgs;
          mkShell {
            buildInputs = [
              rust-bin.stable.latest.default
              rust-analyzer
              taplo
            ];
          };

        packages = rec {
          default =
            (pkgs.makeRustPlatform {
              cargo = pkgs.rust-bin.stable.latest.default;
              rustc = pkgs.rust-bin.stable.latest.default;
            }).buildRustPackage
              {
                pname = "hello-world";
                version = "0.1.0";

                src = ./.;

                cargoLock.lockFile = ./Cargo.lock;
              };
          hello-world = default;
        };
      }
    );
}
