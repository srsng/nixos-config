# 用法：
# 1. 在 VirtualBox 里创建共享文件夹，名称默认是 `nix-cache`，指向宿主机的 `H:\caches\nix-cache`。
# 2. 启用 `srsnn.hostBinaryCache.enable = true;` 并重建系统。
# 3. 进入虚拟机后运行 `sudo host-nix-cache-init`，再把输出的 `.pub` 内容填回 `srsnn.hostBinaryCache.publicKey`。
# 4. 之后可以用 `sudo host-nix-cache-push /nix/store/...` 或 `sudo host-nix-cache-push-current-system` 发布产物。
# 这个模块只负责虚拟机侧挂载、签名和推送，不会在宿主机上启动缓存服务。
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
