{
  nix.settings = {

    substituters = [
      # 国内镜像，走 cache.nixos.org 的签名
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"

      # 官方缓存
      "https://cache.nixos.org/"

      # 项目级公开缓存
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      # 官方 NixOS cache key
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

      # Hyprland Cachix
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="

      # nix-community Cachix
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # 如果以后用了远程 builder，让远程 builder 也优先下载缓存
    builders-use-substitutes = true;

    # 你现在已经是 true，保留即可：相同 store 文件自动硬链接去重
    auto-optimise-store = true;

    # 可选：网络稳定性
    connect-timeout = 15;
    download-attempts = 5;
    http-connections = 25;
  };
}
