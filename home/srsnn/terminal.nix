{
  myvars,
  ...
}:
{
  programs.${myvars.user.terminal} = {
    enable = true;
    # TODO config terminal
    # font = {
    #   name = "Sarasa Mono SC";
    #   size = 12;
    # };
  };
}
