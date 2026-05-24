{ lib }:
let
  user = import ./user.nix { inherit lib; };
in
{
  inherit user;
  # networking = import ./networking.nix { inherit lib; };
}
