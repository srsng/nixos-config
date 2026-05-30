{ ... }:
{
  # UEFI GRUB for the physical seven-nix machine.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    configurationLimit = 5;
  };

  boot.loader.efi.canTouchEfiVariables = true;
}
