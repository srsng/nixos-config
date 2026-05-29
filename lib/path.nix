{
  lib,
  myvars,
  ...
}:
{

  repo_xdg_home = path_str: "${myvars.repo_root}/home/.config/${path_str}";

  # 扫描某个目录，返回其中所有 子目录 和 .nix 文件 的完整路径，但排除 default.nix。
  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
          (_type == "directory") # include directories
          || (
            (path != "default.nix") # ignore default.nix
            && (lib.strings.hasSuffix ".nix" path) # include .nix files
          )
        ) (builtins.readDir path)
      )
    );

}
