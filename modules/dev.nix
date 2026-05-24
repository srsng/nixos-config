{ config, pkgs, ... }:

{
  # Let VS Code Remote-SSH's downloaded server run on NixOS.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
  ];

  # Development tools. Add things here as you learn/need them.
  environment.systemPackages = with pkgs; [
    # Editors and shell basics
    nano
    neovim
    emacs
    less
    bash-completion
    which
    file
    tree

    # Search, navigation and inspection
    ripgrep
    fd
    fzf
    bat
    eza
    jq
    yq-go
    htop
    btop
    procs
    lsof
    strace

    # Disk and performance helpers
    duf
    dust
    ncdu
    hyperfine
    tealdeer

    # Archive/download/transfer
    aria2
    rsync
    p7zip
    zstd
    localsend

    # Network/debug tools
    dnsutils
    inetutils
    iproute2
    nmap
    netcat-openbsd
    tcpdump

    # VS Code with Nix syntax highlighting/LSP support preinstalled.
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        # 语言包
        ms-ceintl.vscode-language-pack-zh-hans
        # 语言支持
        jnoortheen.nix-ide
        sumneko.lua
        # git相关
        mhutchie.git-graph
        eamodio.gitlens
        # 其他优化
        mkhl.direnv   # 自动导入环境变量
        usernamehw.errorlens  # 错误提示
      ];
    })

    # temp
    thunar
    swaybg
    vis
  ];

  # Project-local devShell support: automatically load flake.nix/shell.nix envs.
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
