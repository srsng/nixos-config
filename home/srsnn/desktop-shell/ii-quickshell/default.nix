# from home-module.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.programs.illogical-impulse;
in
{
  # Import all sub-modules
  imports = [
    (import ./fonts.nix inputs)
    (import ./packages.nix inputs)
    (import ./qt.nix inputs)
    (import ./environment.nix inputs)
    (import ./dotfiles.nix inputs)

    ../../../../dotfiles/ii
  ];

  # Main options for Illogical Impulse
  options.programs.illogical-impulse = {
    enable = mkEnableOption "Enable the Illogical Impulse Hyprland configuration";

    # Internal options (not meant to be set by users)
    internal = {
      pythonEnv = mkOption {
        type = types.package;
        internal = true;
        description = "Python environment for QuickShell (internal use only)";
      };
    };
  };
}
