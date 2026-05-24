# home

## 目录结构

```
.                      # main          # not main
├── .config            # xdg公共配置
│   ├── hypr                           # hyprland 配置文件
│   └── hypr.nix                       # hyprland 配置nix入口
├── example.nix        # 用户配置示例
├── README.md                          # 本文件
└── srsnn              # 用户配置目录
    ├── default.nix    # 用户配置入口
    ├── pkgs           # 用户级包
    └── shell.nix                      # 其他自定义配置
```

> inspired by github:Frost-Phoenix/nixos-config

## todo

check list
- [ ] steam.nix
- [ ] pkgs/gui.nix