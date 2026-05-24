
# Host binary cache 模块
#
# 这个模块用于在 VirtualBox NixOS 虚拟机中，把宿主机共享目录作为 Nix binary cache 使用。
# 典型用途是：虚拟机负责构建 Nix store 路径，然后把构建产物导出到宿主机目录；
# 宿主机再用简单 HTTP 服务把该目录发布出去，供本机或局域网其他 NixOS 主机作为缓存服务器使用。
#
# 它主要做这些事：
# 1. 启用 VirtualBox guest 支持。
# 2. 自动挂载宿主机共享文件夹，例如共享名 nix-cache。
# 3. 在共享目录下创建 binary-cache 目录，用来存放 narinfo/nar 等缓存文件。
# 4. 提供 host-nix-cache-init，用于初始化缓存目录并生成 binary cache 签名密钥。
# 5. 提供 host-nix-cache-push / host-nix-cache-push-current-system，用于把指定 store 路径复制进宿主机缓存。
# 6. 可选地把该缓存加入本机 nix.settings.substituters，并配置 trusted-public-keys。
# 7. 可选地启用 post-build-hook，让本机新构建出的结果自动推送到宿主机缓存。
#
# 适合导入这个模块的情况：
# - 当前 NixOS 运行在 VirtualBox 虚拟机里；
# - 宿主机已经创建了 VirtualBox 共享文件夹；
# - 你希望把 Nix 构建产物保存到宿主机磁盘中；
# - 你之后打算在宿主机上启动 HTTP 服务，把这个 binary cache 提供给局域网使用。
#
# 基本使用流程：
# 1. 在宿主机创建目录，例如 H:\caches\nix-cache。
# 2. 在 VirtualBox 中添加共享文件夹，名称建议为 nix-cache，路径指向上面的宿主机目录。
# 3. 在 NixOS 配置中 import 本模块，并启用：
#
#      srsnn.hostBinaryCache.enable = true;
#
# 4. nixos-rebuild switch 后，在虚拟机中运行：
#
#      sudo host-nix-cache-init
#
#    它会初始化缓存目录，并生成 binary cache 签名密钥。
#
# 5. 读取生成的 .pub 公钥文件，把其中一整行填回配置：
#
#      srsnn.hostBinaryCache.publicKey = "srsnn-lan-cache-1:...";
#
#    注意：只复制 .pub 公钥；不要公开 .key 私钥。
#
# 6. 再次 nixos-rebuild switch。
#
# 7. 之后可以手动推送构建产物：
#
#      sudo host-nix-cache-push /nix/store/...
#      sudo host-nix-cache-push-current-system
#
# 常用可配置项：
# - srsnn.hostBinaryCache.enable
#     是否启用本模块。
#
# - srsnn.hostBinaryCache.sharedFolderName
#     VirtualBox 共享文件夹名称，默认通常为 nix-cache。
#
# - srsnn.hostBinaryCache.mountPoint
#     虚拟机内挂载点，例如 /mnt/host-nix-cache。
#
# - srsnn.hostBinaryCache.cacheDir
#     虚拟机内 binary cache 目录，通常位于共享目录下，例如 /mnt/host-nix-cache/binary-cache。
#
# - srsnn.hostBinaryCache.publicKey
#     binary cache 公钥。运行 host-nix-cache-init 后，把 .pub 文件里的整行内容填到这里。
#
# - srsnn.hostBinaryCache.autoPushBuildOutputs
#     是否启用 post-build-hook，让本机新构建结果自动推送到宿主机缓存。
#
# 注意：
# - 这个模块不会把 /nix/store 本身迁移到宿主机。
# - 它管理的是 binary cache，也就是可被 Nix substituter 使用的缓存目录。
# - 宿主机要作为局域网缓存服务器时，还需要额外启动 HTTP 服务来发布 cacheDir 对应目录。

{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf mkMerge mkOption types;
  cfg = config.srsnn.hostBinaryCache;
  shellArg = lib.escapeShellArg;

  # 虚拟机只能通过 VirtualBox 共享文件夹看到缓存；挂载后，Nix 用本地 `file://` 访问。
  cacheUrl = "file://${cfg.cacheDir}";
  cacheUrlWithSecret = "${cacheUrl}?secret-key=${cfg.secretKeyFile}";

  # 每个依赖缓存的命令都会先走这个辅助脚本；它负责确认共享文件夹已挂载。
  ensureHostCacheMount = pkgs.writeShellScriptBin "host-nix-cache-ensure" ''
    set -euo pipefail

    mount_point=${shellArg cfg.mountPoint}
    cache_dir=${shellArg cfg.cacheDir}
    expected_device=${shellArg cfg.sharedFolderName}

    ${pkgs.coreutils}/bin/mkdir -p "$mount_point"

    # systemd automount 会先暴露一层 autofs；真正访问后才会出现 vboxsf。
    # 扫描所有匹配挂载记录。
    is_expected_vboxsf_mount() {
      ${pkgs.util-linux}/bin/findmnt -rno SOURCE,FSTYPE --target "$mount_point" 2>/dev/null \
        | ${pkgs.gnugrep}/bin/grep -Fx -- "$expected_device vboxsf" >/dev/null
    }

    if ! is_expected_vboxsf_mount; then
      ${pkgs.util-linux}/bin/mount "$mount_point" >/dev/null 2>&1 || true
      ${pkgs.coreutils}/bin/ls "$mount_point" >/dev/null 2>&1 || true
    fi

    if ! is_expected_vboxsf_mount; then
      echo "ERROR: $mount_point is not mounted as vboxsf." >&2
      echo "Expected VirtualBox shared-folder name: $expected_device" >&2
      echo "Expected Windows host path: H:\\caches\\nix-cache" >&2
      echo "Current mount state:" >&2
      ${pkgs.util-linux}/bin/findmnt --target "$mount_point" >&2 || true
      exit 1
    fi

    ${pkgs.coreutils}/bin/mkdir -p "$cache_dir"
  '';

  # 初始化路径：在虚拟机里创建缓存目录并生成签名密钥。
  initHostCache = pkgs.writeShellScriptBin "host-nix-cache-init" ''
    set -euo pipefail

    if [ "$(${pkgs.coreutils}/bin/id -u)" != "0" ]; then
      echo "Run as root: sudo host-nix-cache-init" >&2
      exit 1
    fi

    cache_dir=${shellArg cfg.cacheDir}
    key_dir=${shellArg cfg.keyDir}
    secret_key=${shellArg cfg.secretKeyFile}
    public_key=${shellArg cfg.publicKeyFile}

    ${ensureHostCacheMount}/bin/host-nix-cache-ensure
    ${pkgs.coreutils}/bin/install -d -m 0775 "$cache_dir"
    ${pkgs.coreutils}/bin/install -d -m 0700 "$key_dir"

    if [ ! -s "$secret_key" ] || [ ! -s "$public_key" ]; then
      if [ -e "$secret_key" ] || [ -e "$public_key" ]; then
        echo "ERROR: only one of the cache key files exists or a key file is empty." >&2
        echo "Secret key: $secret_key" >&2
        echo "Public key: $public_key" >&2
        echo "Refusing to overwrite key material automatically." >&2
        exit 1
      fi

      umask 077
      ${pkgs.nix}/bin/nix-store --generate-binary-cache-key ${shellArg cfg.keyName} "$secret_key" "$public_key"
      ${pkgs.coreutils}/bin/chmod 0600 "$secret_key"
      ${pkgs.coreutils}/bin/chmod 0644 "$public_key"
    fi

    echo "Host binary cache directory: $cache_dir"
    echo "Binary-cache key directory: $key_dir"
    echo "Public key file: $public_key"
    echo
    echo "Next: read the .pub file and set srsnn.hostBinaryCache.publicKey to that single-line key."
  '';

  # 手动发布路径：把指定的 Nix 存储路径拷到宿主机缓存里。
  pushHostCache = pkgs.writeShellScriptBin "host-nix-cache-push" ''
    set -euo pipefail

    if [ "$(${pkgs.coreutils}/bin/id -u)" != "0" ]; then
      echo "Run as root: sudo host-nix-cache-push /nix/store/..." >&2
      exit 1
    fi
    if [ "$#" -eq 0 ]; then
      echo "Usage: sudo host-nix-cache-push /nix/store/path [more paths...]" >&2
      exit 2
    fi

    secret_key=${shellArg cfg.secretKeyFile}
    to_url=${shellArg cacheUrlWithSecret}

    ${ensureHostCacheMount}/bin/host-nix-cache-ensure
    if [ ! -s "$secret_key" ]; then
      echo "ERROR: cache signing key is missing. Run: sudo host-nix-cache-init" >&2
      exit 1
    fi

    ${pkgs.nix}/bin/nix copy --to "$to_url" "$@"
  '';

  pushCurrentSystem = pkgs.writeShellScriptBin "host-nix-cache-push-current-system" ''
    set -euo pipefail
    exec ${pushHostCache}/bin/host-nix-cache-push /run/current-system
  '';

  # 输出当前挂载、缓存目录和密钥文件状态，方便排障。
  showStatus = pkgs.writeShellScriptBin "host-nix-cache-status" ''
    set -euo pipefail

    mount_point=${shellArg cfg.mountPoint}
    cache_dir=${shellArg cfg.cacheDir}
    secret_key=${shellArg cfg.secretKeyFile}
    public_key=${shellArg cfg.publicKeyFile}

    echo "VirtualBox shared folder: ${cfg.sharedFolderName}"
    echo "Mount point: $mount_point"
    echo "Binary cache URL: ${cacheUrl}"
    echo
    ${pkgs.util-linux}/bin/findmnt --target "$mount_point" || true
    echo
    if [ -d "$cache_dir" ]; then
      ${pkgs.coreutils}/bin/ls -ld "$cache_dir"
      ${pkgs.coreutils}/bin/du -sh "$cache_dir" 2>/dev/null || true
    else
      echo "Cache directory not created yet: $cache_dir"
    fi
    echo
    if [ -s "$secret_key" ]; then
      echo "Secret key: present at $secret_key"
    else
      echo "Secret key: missing; run sudo host-nix-cache-init"
    fi
    if [ -s "$public_key" ]; then
      echo "Public key: present at $public_key"
    else
      echo "Public key: missing; run sudo host-nix-cache-init"
    fi
    if [ -n ${shellArg (if cfg.publicKey == null then "" else cfg.publicKey)} ]; then
      echo
      echo "Nix substituter: configured in the module."
    else
      echo
      echo "Nix substituter: not configured yet; paste the .pub contents into srsnn.hostBinaryCache.publicKey."
    fi
  '';

  # 可选的构建后钩子：启用自动推送时，把新产物拷进缓存。
  postBuildHook = pkgs.writeShellScript "host-binary-cache-post-build-hook" ''
    set -euo pipefail

    secret_key=${shellArg cfg.secretKeyFile}
    to_url=${shellArg cacheUrlWithSecret}

    if [ -z "''${OUT_PATHS:-}" ]; then
      exit 0
    fi
    if [ ! -s "$secret_key" ]; then
      exit 0
    fi

    ${ensureHostCacheMount}/bin/host-nix-cache-ensure >/dev/null 2>&1 || exit 0
    ${pkgs.nix}/bin/nix copy --to "$to_url" ''${OUT_PATHS} >/dev/null 2>&1 || true
  '';
in
{
  # 把模块选项和虚拟机挂载路径、缓存密钥默认值放在一起，方便对照。
  options.srsnn.hostBinaryCache = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the VirtualBox host-backed Nix binary cache skeleton.";
    };

    sharedFolderName = mkOption {
      type = types.str;
      default = "nix-cache";
      description = "VirtualBox shared-folder name, not the Windows path.";
    };

    mountPoint = mkOption {
      type = types.str;
      default = "/mnt/host-nix-cache";
      description = "Guest mount point for the VirtualBox shared folder.";
    };

    cacheDir = mkOption {
      type = types.str;
      default = "/mnt/host-nix-cache/binary-cache";
      description = "Directory used as a Nix file:// binary cache.";
    };

    keyName = mkOption {
      type = types.str;
      default = "srsnn-lan-cache-1";
      description = "Name embedded in the generated binary-cache public key.";
    };

    keyDir = mkOption {
      type = types.str;
      default = "/var/lib/nix-cache-keys";
      description = "Directory holding local binary-cache signing keys.";
    };

    secretKeyFile = mkOption {
      type = types.str;
      default = "/var/lib/nix-cache-keys/srsnn-lan-cache-1.sec";
      description = "Secret signing key used only by root-side cache push commands.";
    };

    publicKeyFile = mkOption {
      type = types.str;
      default = "/var/lib/nix-cache-keys/srsnn-lan-cache-1.pub";
      description = "Public signing key generated by host-nix-cache-init.";
    };

    publicKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Public key trusted by this machine for the host binary cache.";
    };

    autoPushBuildOutputs = mkOption {
      type = types.bool;
      default = false;
      description = "If true, try to copy new local build outputs into the host binary cache after each build.";
    };
  };

  # 只有启用模块时，才一起装配虚拟机挂载、辅助脚本和可选的缓存配置。
  config = mkIf cfg.enable (mkMerge [
    {
      virtualisation.virtualbox.guest.enable = true;

      fileSystems.${cfg.mountPoint} = {
        device = cfg.sharedFolderName;
        fsType = "vboxsf";
        options = [
          "rw"
          "uid=0"
          "gid=0"
          "dmode=0775"
          "fmode=0664"
          "umask=0002"
          "x-systemd.automount"
          "noauto"
          "nofail"
        ];
        neededForBoot = false;
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.mountPoint} 0755 root root -"
        "d ${cfg.keyDir} 0700 root root -"
      ];

      environment.systemPackages = [
        ensureHostCacheMount
        initHostCache
        pushHostCache
        pushCurrentSystem
        showStatus
      ];
    }
    (mkIf (cfg.publicKey != null) {
      nix.settings.substituters = [ cacheUrl ];
      nix.settings."trusted-public-keys" = [ cfg.publicKey ];
    })
    (mkIf cfg.autoPushBuildOutputs {
      nix.settings."post-build-hook" = "${postBuildHook}";
    })
  ]);
}
