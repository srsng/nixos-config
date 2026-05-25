{
  pkgs,
  config,
  ...
}:
{
  home.packages = with pkgs; [ fastfetch ];

  # TODO: or Frost-Phoenix-nixos-config-fastftech.jsonc
  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch/Horizon0427-Arch-Config-fastfetch.jsonc;  
}
