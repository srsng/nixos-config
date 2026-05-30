{ pkgs, mylib, ... }:
{
  # better cat/less
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "gruvbox-dark";
    };
    extraPackages = with pkgs.bat-extras; [
      batman
      batpipe
      batgrep
      batdiff
    ];
  };
}
