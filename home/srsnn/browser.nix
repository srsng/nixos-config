{
  pkgs,
  config,
  myvars,
  ...
}:
{
  # TODO: be careful when switching to other browser.
  programs.${myvars.user.browser} = {
    enable = true;
    # xdg.configFile."mozilla/${myvars.user.browser}"
    configPath = "${config.xdg.configHome}/mozilla/${myvars.user.browser}";
  };

  # TODO: nixpaks
  # home.packages = with pkgs; [
  #   nixpaks.firefox
  # ];

  # TODO
  # # source code: https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
  # programs.google-chrome = {
  #   enable = true;
  #   package = if pkgs.stdenv.isAarch64 then pkgs.chromium else pkgs.google-chrome;
  # };
}
