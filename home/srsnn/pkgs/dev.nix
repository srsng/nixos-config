{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Nix
    nixd # nix lsp
    nixfmt # 格式化
    statix # lint
    deadnix # 检测未使用的 Nix 变量/代码
    nh # 更友好的 NixOS/Home Manager rebuild 工具

    ## formating
    shfmt
    treefmt

    ## lint/checker
    shellcheck
    
    # ## C / C++
    # gcc
    # gdb
    # gef
    # cmake
    # gnumake
    # valgrind
    # llvmPackages_20.clang-tools

    ## Python
    uv
    # python312.out
    # python312Packages.ipython

    ## rust
    rustup

    ## javascript
    nodejs
  ];
}
