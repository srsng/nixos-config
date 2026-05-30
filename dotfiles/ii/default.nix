# dotfiles: github:end-4/dots-hyprland (illogical-impulse)

{
  config,
  pkgs,
  lib,
  myvars,
  mylib,
  ...
}:
let
  # 绝对路径链接到这个目录的dotfiles
  link_to_ii_dot =
    path: config.lib.file.mkOutOfStoreSymlink "${myvars.repo_root}/dotfiles/ii/${toString path}";

  mkConfigs =
    files:
    builtins.mapAttrs (_target: source: {
      source = link_to_ii_dot source;
    }) files;

  mkConfigsForce =
    files:
    builtins.mapAttrs (_target: source: {
      source = lib.mkForce (link_to_ii_dot source);
      # force = true;
    }) files;

  xdg_configs_root = "./.config";
  xdg_configs = {
    "chrome-flags.conf" = "${xdg_configs_root}/chrome-flags.conf";
    "code-flags.conf" = "${xdg_configs_root}/code-flags.conf";
    "darklyrc" = "${xdg_configs_root}/darklyrc";
    "dolphinrc" = "${xdg_configs_root}/dolphinrc";
    "fish/auto-Hypr.fish" = "${xdg_configs_root}/fish/auto-Hypr.fish";
    # "fish/config.fish" = "${xdg_configs_root}/fish/config.fish";
    "fish/fish_variables" = "${xdg_configs_root}/fish/fish_variables";
    "fontconfig/fonts.conf" = "${xdg_configs_root}/fontconfig/fonts.conf";
    "foot" = "${xdg_configs_root}/foot";
    "fuzzel" = "${xdg_configs_root}/fuzzel";
    "hypr" = "${xdg_configs_root}/hypr";
    "illogical-impulse" = "${xdg_configs_root}/illogical-impulse";
    "kdeglobals" = "${xdg_configs_root}/kdeglobals";
    "kde-material-you-colors" = "${xdg_configs_root}/kde-material-you-colors";
    "kitty" = "${xdg_configs_root}/kitty";
    "konsolerc" = "${xdg_configs_root}/konsolerc";
    "Kvantum" = "${xdg_configs_root}/Kvantum";
    "matugen" = "${xdg_configs_root}/matugen";
    "mpv" = "${xdg_configs_root}/mpv";
    "quickshell" = "${xdg_configs_root}/quickshell";
    # "starship.toml" = "${xdg_configs_root}/starship.toml";
    "thorium-flags.conf" = "${xdg_configs_root}/thorium-flags.conf";
    "wlogout" = "${xdg_configs_root}/wlogout";
    "xdg-desktop-portal" = "${xdg_configs_root}/xdg-desktop-portal";
    "zshrc.d" = "${xdg_configs_root}/zshrc.d";
  };

  xdg_configs_force = {
    "fish/config.fish" = "${xdg_configs_root}/fish/config.fish";
  };

  local_files_root = "./.local";
  local_files = {
    ".local/share/icons" = "${local_files_root}/share/icons";
    ".local/share/konsole" = "${local_files_root}/share/konsole";
  };
in
{

  xdg.configFile = lib.mkMerge [
    (mkConfigs xdg_configs)
    (mkConfigsForce xdg_configs_force)
  ];

  home.file = lib.mkMerge [
    (mkConfigs  local_files)
  ];
}
