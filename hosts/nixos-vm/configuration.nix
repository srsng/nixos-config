{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/cache.nix
    ../../modules/base.nix
    ../../modules/desktop-hyprland.nix
    ../../modules/dev.nix
    ../../modules/ssh.nix
  ];

  networking.hostName = "nixos";

  # Keep this at the release version used for the first install.
  # Do not change it just because you upgrade nixpkgs.
  system.stateVersion = "25.11";
}
