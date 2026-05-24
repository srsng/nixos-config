{ pkgs, ... }:
{
  # TODO
  home.packages = with pkgs; [
    #   ## Multimedia
    #   amberol # music player
    #   audacity
    #   gimp
    #   media-downloader
    #   obs-studio
    #   pavucontrol
    #   video-trimmer
    #   vlc

    #   ## Office
    #   libreoffice
    #   gnome-calculator

    #   ## Utility
    #   dconf-editor
    #   gnome-disk-utility
    #   popsicle
    #   mission-center # GUI resources monitor
    #   zenity

    #   ## Level editor
    #   ldtk
    #   tiled

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
        mkhl.direnv # 自动导入环境变量
        usernamehw.errorlens # 错误提示
      ];
    })
  ];
}
