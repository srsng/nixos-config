{
  inputs,
  ...
}:
{
  # need to add this to flake.nix
  # inputs.caelestia-shell = {
  #   url = "github:caelestia-dots/shell";
  #   inputs.nixpkgs.follows = "nixpkgs";
  # };
  # get dot files from: github:caelestia-dots/caelestia

  imports = [ inputs.caelestia-shell.homeManagerModules.default ];

  programs.caelestia = {
    enable = true;
    systemd = {
      enable = false; # if you prefer starting from your compositor
      target = "graphical-session.target";
      environment = [ ];
    };
    settings = {
      bar.status = {
        showBattery = false;
      };
      paths.wallpaperDir = "~/Images";
    };
    cli = {
      enable = true; # Also add caelestia-cli to path
      settings = {
        theme.enableGtk = false;
      };
    };
  };
}
