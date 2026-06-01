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

  ${myvars.user.name}.localCache.enable = true;

  # Required services
  services.geoclue2.enable = true; # For QtPositioning
  # services.networkmanager.enable = true; # For network management

  # Keep this at the release version used for the first install.
  # Do not change it just because you upgrade nixpkgs.

  system.stateVersion = "26.05";
}
