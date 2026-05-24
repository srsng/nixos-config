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

  programs.firefox.enable = true;

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

  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];

  environment.systemPackages = with pkgs; [
    kdePackages.kate
    foot
    waybar
    rofi
    hyprpaper
    grim
    slurp
    pavucontrol
    hyprlauncher
    networkmanagerapplet
    # hyprpolkitagent
    wl-clipboard
  ];
}
