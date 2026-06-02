{ 
  myvars,
  ...
}:
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

  # Enable the host-side network push workflow for this VM profile.
  ${myvars.user.name}.hostBinaryCache.enable = true;
}
