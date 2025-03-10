{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    {
      overlays.default = _: prev: {
        hello-world = self.packages.${prev.stdenv.hostPlatform.system}.default;
      };
      overlays.hello-world = self.overlays.default;

      nixosModules.default = import ./default.nix inputs;
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

        packages.default =
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
        packages.hello-world = self.packages.default;

      }
    );
}
