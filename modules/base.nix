{ config, pkgs, lib, ... }:

{
  # Nix basics
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  # Faster downloads in China. Security is still enforced by Nix signatures.
  # These mirrors serve cache.nixos.org objects signed by Nix's built-in official key.
  nix.settings.substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://cache.nixos.org/"
  ];
  nix.settings.require-sigs = true;

  nixpkgs.config.allowUnfree = true;

  # Avoid globally installing package doc outputs; python312 doc fails to build.
  environment.extraOutputsToInstall = lib.mkForce [ "man" "info" ];

  # Bootloader for this VirtualBox BIOS VM.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Networking
  networking.networkmanager.enable = true;

  # Locale/timezone
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # User
  users.users.srsnn = {
    isNormalUser = true;
    description = "srsnn";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # A small useful baseline. Keep large app choices in modules/dev.nix or desktop module.
  environment.systemPackages = with pkgs; [
    curl
    git
    vim
    wget
  ];
}
