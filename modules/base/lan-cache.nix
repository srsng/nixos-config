{ config, lib,
myvars, ... }:

let
  inherit (lib) mkIf mkOption types;
  cfg = config.${myvars.user.name}.localCache;
in
{
  options.${myvars.user.name}.localCache = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the LAN Nix binary cache substituter.";
    };

    url = mkOption {
      type = types.str;
      default = "http://192.168.31.194:35428";
      description = "LAN Nix binary cache URL.";
    };

    publicKey = mkOption {
      type = types.str;
      default = "srsnn-lan-cache-1:LFolmd5ljszL5skFL3X5plj9/D6fkYOKNJJA8mxcdMY=";
      description = "Public key trusted for the LAN Nix binary cache.";
    };
  };

  config = mkIf cfg.enable {
    nix.settings.substituters = lib.mkBefore [
      cfg.url
    ];

    nix.settings.trusted-public-keys = lib.mkBefore [
      cfg.publicKey
    ];
  };
}
