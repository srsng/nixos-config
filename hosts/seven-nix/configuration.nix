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
    ../../modules/base
    ../../modules/desktop-hyprland.nix
  ];

  networking.hostName = "seven-nix";

  services.geoclue2.enable = true; # For QtPositioning

  system.stateVersion = "26.05";
}
