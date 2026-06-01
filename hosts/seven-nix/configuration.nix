{
  config,
  lib,
  pkgs,
  inputs,
  myvars,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ../../modules/base.nix
    ../../modules/desktop-hyprland.nix
    ../../modules/dev.nix
    ../../modules/ssh.nix
  ];

  networking.hostName = "seven-nix";

  services.geoclue2.enable = true; # For QtPositioning

  system.stateVersion = "26.05";
}
