{
  config,
  pkgs,
  lib,
  myvars,
  ...
}:

{
  # Nix basics
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
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
  users.users.${myvars.user.name} = {
    isNormalUser = true;
    description = "${myvars.user.name}";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      sarasa-gothic
      source-han-sans
      source-han-serif
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "Noto Sans CJK SC"
          "Sarasa Gothic SC"
        ];
        serif = [
          "Noto Serif CJK SC"
          "Source Han Serif SC"
        ];
        monospace = [
          "Sarasa Mono SC"
          "Noto Sans Mono CJK SC"
        ];
        emoji = [
          "Noto Color Emoji"
        ];
      };
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # A small useful baseline. Keep large app choices in modules/dev.nix or desktop module.
  environment.systemPackages = with pkgs; [

    # Archive/download/transfer
    curl
    wget
    xz
    unzip
    zip

    # common utils
    git
    vim
    udiskie                           # Automounter for removable media

    # for Nvidia
    # nvidia-dkms
    # nvidia-utils
  ];
}
