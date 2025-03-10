inputs:
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
    package = lib.mkPackageOption pkgs "hello-world" { };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.self.overlays.default ];

    environment.systemPackages = [
      pkgs.hello-world
    ];
  };
}
