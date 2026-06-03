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
    ./virtualbox.nix
    ../../modules/base
    ../../modules/desktop-hyprland.nix
  ];

  networking.hostName = "nixos-vm";

  # 局域网缓存服务器
  ${myvars.user.name}.localCache.enable = true;

  # Required services
  services.geoclue2.enable = true; # For QtPositioning
  # services.networkmanager.enable = true; # For network management

  # Keep this at the release version used for the first install.
  # Do not change it just because you upgrade nixpkgs.
  system.stateVersion = "25.11";
}
