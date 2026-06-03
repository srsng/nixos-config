{ lib, mylib, ... }:
{
  imports = mylib.scanPaths ./.;

  # Avoid globally installing package doc outputs; python312 doc fails to build.
  environment.extraOutputsToInstall = lib.mkForce [
    "man"
    "info"
  ];

  # Networking
  networking.networkmanager.enable = true;
}
