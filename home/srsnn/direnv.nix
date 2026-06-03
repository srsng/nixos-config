{
  # Project-local devShell support: automatically load flake.nix/shell.nix envs.
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;

    nix-direnv.enable = true;
  };
}
