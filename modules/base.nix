{
  config,
  pkgs,
  lib,
  myvars,
  ...
}:

{
  imports = [
    ./base
  ];

  # Avoid globally installing package doc outputs; python312 doc fails to build.
  environment.extraOutputsToInstall = lib.mkForce [
    "man"
    "info"
  ];

  # Bootloader for this VirtualBox BIOS VM.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Networking
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
