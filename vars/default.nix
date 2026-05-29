{ lib }:
let
  user = import ./user.nix { inherit lib; };
  repo_name = "nixos-config";
in
{
  inherit user;
  repo_root = "/home/${user.name}/${repo_name}";
  # networking = import ./networking.nix { inherit lib; };
}
