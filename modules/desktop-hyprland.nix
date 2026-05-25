{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # Desktop
  services.xserver.enable = true;
  services.displayManager.ly.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  # services.displayManager.defaultSession = "hyprland";

  # X11 keyboard layout. Wayland/Plasma can still be adjusted in System Settings.
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  security.polkit.enable = true;

  # Printing
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  hardware.graphics = {
    enable = true;
    # Steam / 32-bit
    # enable32Bit = true;
  };

  # hyprland
  # use build cache
  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
    ];

    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # withUWSM = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # xdg.portal = {
  #   enable = true;
  #   # Hyprland module 会加入 xdg-desktop-portal-hyprland。
  #   # gtk portal 主要补文件选择器等常见桌面能力。
  #   extraPortals = with pkgs; [
  #     xdg-desktop-portal-gtk
  #   ];
  # };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # networking.firewall.allowedTCPPorts = [ 53317 ];
  # networking.firewall.allowedUDPPorts = [ 53317 ];

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
      qt6Packages.fcitx5-configtool
      fcitx5-gtk
      fcitx5-pinyin-zhwiki
    ];
  };

  # services.swaync

  environment.systemPackages = with pkgs; [
    # Hyprland desktop base
    waybar
    foot
    rofi
    swaybg
    mako
    libnotify

    # Auth / portal / session helpers
    polkit_gnome
    xdg-utils

    # File management
    kdePackages.dolphin
    kdePackages.kio-extras
    kdePackages.ark
    kdePackages.gwenview
    kdePackages.okular
    trash-cli

    # Audio/network/bluetooth
    networkmanagerapplet
    pavucontrol
    playerctl
    blueman

    # Clipboard/screenshot
    wl-clipboard
    cliphist
    grim
    slurp
    swappy
    hyprpicker

    # Lock/idle/power
    hyprlock
    hypridle
    brightnessctl

    # Keyring/tools
    seahorse
  ];

  # environment.systemPackages = with pkgs; [
  #   kdePackages.kate

  #   hyprpaper
  #   hyprlauncher
  #   networkmanagerapplet
  # hyprpolkitagent

  #   # polkit
  #   # agent
  # udisks2
  # ];
}
