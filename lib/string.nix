{
  lib,
  ...
}:
{
  # e.g. "nixos" -> "Nixos"
  capitalize =
    s:
    let
      len = builtins.stringLength s;
    in
    if len == 0 then
      ""
    else
      lib.toUpper (builtins.substring 0 1 s) + lib.toLower (builtins.substring 1 (len - 1) s);
}
