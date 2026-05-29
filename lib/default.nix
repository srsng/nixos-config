{
  lib,
  myvars,
  ...
}:
let
  string = import ./string.nix { inherit lib; };
  path = import ./path.nix { inherit lib myvars; };
in
{
  inherit string;
  inherit (string) capitalize;
  inherit path;
  inherit (path) repo_xdg_home scanPaths;
}
