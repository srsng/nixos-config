{
  config,
  pkgs,
  lib,
  myvars,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    # for Nvidia  https://wiki.hypr.land/Nvidia/
    nvidia-dkms
    nvidia-utils
    egl-wayland
  ];
}
