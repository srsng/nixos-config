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

    ## Lisp / Scheme
    guile # GNU Guile
    guile-lsp-server # Helix scheme LSP
    schemat # Scheme formatter for Helix
    racket # Racket runtime/toolchain
    chez # Chez Scheme
    chickenPackages_5.chicken # CHICKEN Scheme
    gambit # Gambit Scheme
    chibi # Chibi Scheme
    rlwrap # nicer REPL editing/history
  ];

  # TODO: helix config
  xdg.configFile."helix/languages.toml".text = ''
    [language-server.guile-lsp-server]
    command = "guile-lsp-server"

    [[language]]
    name = "scheme"
    language-servers = ["guile-lsp-server"]
    formatter = { command = "schemat" }
  '';
}
