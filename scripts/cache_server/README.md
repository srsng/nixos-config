# LAN Nix Cache Server

网络 binary cache 服务端：HTTP 对外发布缓存目录，FTPS 或其他上传通道把 `.narinfo` / `nar/*` 写入同一个 `cache_root`，超过 200GB 后按旧 `.narinfo` 回收到约 180GB。

## 入口

在仓库根目录执行：

```text
just cache
just cache help
just cache init
just cache serve-dry-run
just cache serve
just cache check
just cache status
just cache push
just cache prune-dry-run
just cache prune
just cache python-check
```

日常只需要记住根目录 `just cache <命令>`；业务逻辑都在 `scripts/cache_server/core/*.py`，旧包装脚本已移除。`just cache status` / `just cache push` 只在启用 `hostBinaryCache` 并重建后的 NixOS 客户端上使用。

## 配置

编辑 `cache_server.toml`：

```toml
cache_root = '/srv/nix-cache/binary-cache'

[http]
bind = '127.0.0.1'
port = 35428

[limits]
max_cache_bytes = 214748364800

[prune]
high_watermark_bytes = 214748364800
low_watermark_bytes = 193273528320
```

`cache_root` 是网络缓存的存储边界：HTTP 服务从这里读，FTPS 或其他上传通道也写到这里；按服务端系统填写对应路径。

## 前提

- 已安装 `just`、`uv`
- Python 3.11+
- `cache_root` 同时作为 HTTP 根目录与 FTPS 上传目录

## 提醒

- FTPS 站点根目录应指向同一个 `cache_root`
- 禁止匿名访问，使用专用上传账号，开启 TLS
- NixOS 客户端的缓存消费配置放在 `modules/base/lan-cache.nix`
- public key 可公开；signing secret key 与 FTPS 凭据不能进入 `/nix/store`
