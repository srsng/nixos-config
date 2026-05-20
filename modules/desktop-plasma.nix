{ config, pkgs, ... }:

{
  # Desktop
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # X11 keyboard layout. Wayland/Plasma can still be adjusted in System Settings.
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  # Printing
  services.printing.enable = true;

  # Sound with PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.kate
  ];
}
