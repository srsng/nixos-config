{
  myvars,
  ...
}:
let
  shellAliases = {
    # "ls" = "eza";
    "ll" = "eza -l";
    "la" = "eza -la";
    ".." = "cd ..";
  };
in
{
  programs.bash = {
    enable = true;
    shellAliases = shellAliases;
  };

  programs.${myvars.user.shell} = {
    enable = true;
    shellAliases = shellAliases;
  };
}
