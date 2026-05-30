{ ... }:
{
  imports = [
    ../../modules/host-binary-cache.nix
  ];

  # Bootloader for the VirtualBox BIOS VM.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  # Host-backed binary cache is VirtualBox-specific: enables vbox guest support
  # and mounts the host shared folder through vboxsf.
  srsnn.hostBinaryCache.enable = true;
}
