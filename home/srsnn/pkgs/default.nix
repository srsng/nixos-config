{ ... }:
{
  # 用户私有包
  imports = [
    ./cli.nix
    ./dev.nix
    # ./gui.nix
    ./nix.nix
  ];
}
