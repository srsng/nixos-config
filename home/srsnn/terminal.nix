{
  myvars,
  ...
}:
{
  programs.${myvars.user.terminal} = {
    enable = true;
    # font = {
    #   name = "Sarasa Mono SC";
    #   size = 12;
    # };
  };
}
