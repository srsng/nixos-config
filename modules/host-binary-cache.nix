# Host binary cache 模块
#
# 这个模块用于在 NixOS 主机上：
# 1. 本地生成/保存 binary cache signing key。
# 2. 将构建产物先导出到本地 staging 目录。
# 3. 通过 post-build-hook 把 OUT_PATHS 追加到队列。
# 4. 由 systemd service/timer 异步 flush 队列，并通过 FTPS 上传到网络缓存端点。
# 5. 提供当前系统 closure 的手动推送入口。
#
# 安全边界：
# - secret key 与 FTPS 凭据都只通过运行时路径引用，不能进入 /nix/store。
# - public key 可公开；真正敏感的是 signing secret key。
# - 默认采用 fail-open：上传失败不阻塞本地构建。

{ config, 
  lib,
  pkgs,
  myvars,
  ...
}:

let
  inherit (lib) escapeShellArg mkEnableOption mkIf mkMerge mkOption types;
  cfg = config.${myvars.user.name}.hostBinaryCache;
  shellArg = escapeShellArg;

  cacheUrl = cfg.cacheUrl;
  stagingUrl = "file://${cfg.stagingDir}?secret-key=${cfg.secretKeyFile}";

  initHostCache = pkgs.writeShellScriptBin "host-nix-cache-init" ''
    set -euo pipefail

    key_dir=${shellArg cfg.keyDir}
    secret_key=${shellArg cfg.secretKeyFile}
    public_key=${shellArg cfg.publicKeyFile}
    key_name=${shellArg cfg.keyName}
    staging_dir=${shellArg cfg.stagingDir}
    queue_file=${shellArg cfg.queueFile}

    ${pkgs.coreutils}/bin/mkdir -p "$key_dir" "$staging_dir" "$staging_dir/nar" "$(${pkgs.coreutils}/bin/dirname "$queue_file")"
    ${pkgs.coreutils}/bin/touch "$queue_file"
    ${pkgs.coreutils}/bin/chmod 0700 "$key_dir"
    ${pkgs.coreutils}/bin/chmod 0755 "$staging_dir" "$staging_dir/nar"
    ${pkgs.coreutils}/bin/chmod 0600 "$queue_file"

    if [ ! -s "$secret_key" ] || [ ! -s "$public_key" ]; then
      ${pkgs.nix}/bin/nix key generate-secret --key-name "$key_name" > "$secret_key"
      ${pkgs.nix}/bin/nix key convert-secret-to-public < "$secret_key" > "$public_key"
      ${pkgs.coreutils}/bin/chmod 0600 "$secret_key"
      ${pkgs.coreutils}/bin/chmod 0644 "$public_key"
      echo "Generated cache signing keypair: $key_name"
    else
      echo "Signing keypair already exists."
    fi

    if [ ! -e "$staging_dir/nix-cache-info" ]; then
      cat > "$staging_dir/nix-cache-info" <<'EOF'
StoreDir: /nix/store
WantMassQuery: 1
Priority: 30
EOF
      ${pkgs.coreutils}/bin/chmod 0644 "$staging_dir/nix-cache-info"
      echo "Created $staging_dir/nix-cache-info"
    fi

    echo
    echo "Public key file: $public_key"
    echo "Paste this into clients if needed:"
    ${pkgs.coreutils}/bin/cat "$public_key"
  '';

  enqueueHostCache = pkgs.writeShellScriptBin "host-nix-cache-enqueue" ''
    set -euo pipefail

    queue_file=${shellArg cfg.queueFile}
    queue_dir="$(${pkgs.coreutils}/bin/dirname "$queue_file")"
    ${pkgs.coreutils}/bin/mkdir -p "$queue_dir"
    ${pkgs.coreutils}/bin/touch "$queue_file"
    ${pkgs.coreutils}/bin/chmod 0600 "$queue_file" || true

    for path in "$@"; do
      [ -n "$path" ] || continue
      printf '%s\n' "$path" >> "$queue_file"
    done
  '';

  pushCurrentSystem = pkgs.writeShellScriptBin "host-nix-cache-push-current-system" ''
    set -euo pipefail
    exec ${enqueueHostCache}/bin/host-nix-cache-enqueue /run/current-system
  '';

  flushHostCache = pkgs.writeShellScriptBin "host-nix-cache-flush" ''
    set -euo pipefail

    queue_file=${shellArg cfg.queueFile}
    queue_dir="$(${pkgs.coreutils}/bin/dirname "$queue_file")"
    lock_dir=${shellArg cfg.lockDir}
    secret_key=${shellArg cfg.secretKeyFile}
    credentials_file=${shellArg cfg.credentialsFile}
    staging_dir=${shellArg cfg.stagingDir}
    host=${shellArg cfg.ftpHost}
    port=${toString cfg.ftpPort}
    remote_dir=${shellArg cfg.ftpRemoteDir}
    fail_open="''${HOST_NIX_CACHE_FAIL_OPEN:-${if cfg.failOpen then "1" else "0"}}"

    ${pkgs.coreutils}/bin/mkdir -p "$queue_dir" "$lock_dir" "$staging_dir" "$staging_dir/nar"
    ${pkgs.coreutils}/bin/touch "$queue_file"

    lockfile="$lock_dir/flush.lock"
    exec 9> "$lockfile"
    if ! ${pkgs.util-linux}/bin/flock -n 9; then
      echo "Another flush is running; skip."
      exit 0
    fi

    if [ ! -s "$secret_key" ]; then
      echo "Signing secret key missing: $secret_key" >&2
      if [ "$fail_open" = 1 ]; then exit 0; else exit 1; fi
    fi
    if [ ! -s "$credentials_file" ]; then
      echo "FTPS credentials file missing: $credentials_file" >&2
      if [ "$fail_open" = 1 ]; then exit 0; else exit 1; fi
    fi

    mapfile -t queued < "$queue_file"
    if [ "''${#queued[@]}" -eq 0 ]; then
      echo "Queue is empty."
      exit 0
    fi

    declare -A seen=()
    unique=()
    for path in "''${queued[@]}"; do
      [ -n "$path" ] || continue
      if [ -e "$path" ] || [ "$path" = "/run/current-system" ]; then
        if [ -z "''${seen[$path]+x}" ]; then
          seen[$path]=1
          unique+=("$path")
        fi
      else
        echo "Skip missing path: $path" >&2
      fi
    done

    if [ "''${#unique[@]}" -eq 0 ]; then
      : > "$queue_file"
      echo "Queue had no usable paths."
      exit 0
    fi

    ${pkgs.nix}/bin/nix copy --to ${shellArg stagingUrl} "''${unique[@]}"

    tmp_script="$(${pkgs.coreutils}/bin/mktemp)"
    tmp_remaining="$(${pkgs.coreutils}/bin/mktemp)"
    trap '${pkgs.coreutils}/bin/rm -f "$tmp_script" "$tmp_remaining"' EXIT

    cat > "$tmp_script" <<EOF
set ssl:verify-certificate no
set net:max-retries 1
set net:timeout 20
open -u \"$(${pkgs.gnused}/bin/sed -n '1p' \"$credentials_file\")\",\"$(${pkgs.gnused}/bin/sed -n '2p' \"$credentials_file\")\" ftps://$host:$port
mkdir -p $remote_dir
cd $remote_dir
mirror -R --only-newer --parallel=1 --include-glob nar/** --exclude-glob *.narinfo --exclude-glob nix-cache-info ${shellArg cfg.stagingDir} .
put -O . ${shellArg "${cfg.stagingDir}/nix-cache-info"}
mput -O . ${shellArg "${cfg.stagingDir}"}/*.narinfo
bye
EOF

    if ! ${pkgs.lftp}/bin/lftp -f "$tmp_script"; then
      echo "FTPS upload failed." >&2
      if [ "$fail_open" = 1 ]; then exit 0; else exit 1; fi
    fi

    : > "$tmp_remaining"
    for path in "''${unique[@]}"; do
      printf '%s\n' "$path" >> "$tmp_remaining"
    done
    ${pkgs.coreutils}/bin/cp "$tmp_remaining" "$queue_file.processed"
    : > "$queue_file"

    ${pkgs.findutils}/bin/find "$staging_dir" -mindepth 1 -exec ${pkgs.coreutils}/bin/rm -rf -- {} +
    ${pkgs.coreutils}/bin/mkdir -p "$staging_dir/nar"
    cat > "$staging_dir/nix-cache-info" <<'EOF'
StoreDir: /nix/store
WantMassQuery: 1
Priority: 30
EOF
    ${pkgs.coreutils}/bin/chmod 0644 "$staging_dir/nix-cache-info"

    echo "Flushed ''${#unique[@]} queued paths to $host:$port$remote_dir"
  '';

  showStatus = pkgs.writeShellScriptBin "host-nix-cache-status" ''
    set -euo pipefail

    queue_file=${shellArg cfg.queueFile}
    staging_dir=${shellArg cfg.stagingDir}
    secret_key=${shellArg cfg.secretKeyFile}
    public_key=${shellArg cfg.publicKeyFile}
    credentials_file=${shellArg cfg.credentialsFile}

    echo "HTTP cache URL: ${cfg.cacheUrl}"
    echo "FTPS endpoint : ${cfg.ftpHost}:${toString cfg.ftpPort}${cfg.ftpRemoteDir}"
    echo "Staging dir   : $staging_dir"
    echo "Queue file    : $queue_file"
    echo

    if [ -d "$staging_dir" ]; then
      ${pkgs.coreutils}/bin/ls -ld "$staging_dir"
      ${pkgs.coreutils}/bin/du -sh "$staging_dir" 2>/dev/null || true
    else
      echo "Staging directory missing: $staging_dir"
    fi
    echo

    if [ -f "$queue_file" ]; then
      count="$(${pkgs.coreutils}/bin/wc -l < "$queue_file" | ${pkgs.gnused}/bin/sed 's/ //g')"
      echo "Queued paths: $count"
    else
      echo "Queue file not created yet."
    fi

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
    if [ -s "$credentials_file" ]; then
      echo "Credentials: present at $credentials_file"
    else
      echo "Credentials: missing at $credentials_file"
    fi

    if [ -n ${shellArg (if cfg.publicKey == null then "" else cfg.publicKey)} ]; then
      echo
      echo "Nix substituter: configured in the module."
    else
      echo
      echo "Nix substituter: not configured yet; paste the .pub contents into ${myvars.user.name}.hostBinaryCache.publicKey."
    fi
  '';

  postBuildHook = pkgs.writeShellScript "host-binary-cache-post-build-hook" ''
    set -eu

    if [ -z "''${OUT_PATHS:-}" ]; then
      exit 0
    fi

    ${enqueueHostCache}/bin/host-nix-cache-enqueue ''${OUT_PATHS} >/dev/null 2>&1 || true
  '';
in
{
  options.${myvars.user.name}.hostBinaryCache = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable FTPS-backed Nix binary cache push workflow.";
    };

    cacheUrl = mkOption {
      type = types.str;
      default = "http://192.168.56.1:35428";
      description = "HTTP URL used by this machine as a Nix substituter.";
    };

    uploadMethod = mkOption {
      type = types.enum [ "ftps" ];
      default = "ftps";
      description = "Upload transport for pushing cached artifacts.";
    };

    ftpHost = mkOption {
      type = types.str;
      default = "192.168.56.1";
      description = "FTPS server hostname or IP.";
    };

    ftpPort = mkOption {
      type = types.port;
      default = 21;
      description = "FTPS control port.";
    };

    ftpRemoteDir = mkOption {
      type = types.str;
      default = "/";
      description = "Remote FTPS directory that maps to the HTTP cache root.";
    };

    credentialsFile = mkOption {
      type = types.str;
      default = "/run/secrets/nix-cache-ftps";
      description = "Runtime credentials file: line1=username, line2=password.";
    };

    keyName = mkOption {
      type = types.str;
      default = "${myvars.user.name}-lan-cache-1";
      description = "Name embedded in the generated binary-cache public key.";
    };

    keyDir = mkOption {
      type = types.str;
      default = "/var/lib/nix-cache-keys";
      description = "Directory holding local binary-cache signing keys.";
    };

    secretKeyFile = mkOption {
      type = types.str;
      default = "/var/lib/nix-cache-keys/${myvars.user.name}-lan-cache-1.sec";
      description = "Secret signing key used only by root-side staging/flush commands.";
    };

    publicKeyFile = mkOption {
      type = types.str;
      default = "/var/lib/nix-cache-keys/${myvars.user.name}-lan-cache-1.pub";
      description = "Public signing key generated by host-nix-cache-init.";
    };

    publicKey = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Public key trusted by this machine for the LAN binary cache.";
    };

    stagingDir = mkOption {
      type = types.str;
      default = "/var/lib/host-binary-cache/staging";
      description = "Local file:// cache staging directory before FTPS upload.";
    };

    queueFile = mkOption {
      type = types.str;
      default = "/var/lib/host-binary-cache/queue/pending.txt";
      description = "Queue file storing out paths waiting to be flushed.";
    };

    lockDir = mkOption {
      type = types.str;
      default = "/var/lib/host-binary-cache/lock";
      description = "Directory used for flush lock files.";
    };

    flushInterval = mkOption {
      type = types.str;
      default = "5min";
      description = "systemd timer interval for background queue flush.";
    };

    autoPushBuildOutputs = mkOption {
      type = types.bool;
      default = false;
      description = "If true, append new local build outputs to the upload queue after each build.";
    };

    failOpen = mkOption {
      type = types.bool;
      default = true;
      description = "If true, upload failures never fail the build path or timer invocation.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.uploadMethod == "ftps";
          message = "${myvars.user.name}.hostBinaryCache.uploadMethod currently only supports ftps.";
        }
      ];

      systemd.tmpfiles.rules = [
        "d ${cfg.keyDir} 0700 root root -"
        "d ${cfg.stagingDir} 0755 root root -"
        "d ${cfg.stagingDir}/nar 0755 root root -"
        "d ${builtins.dirOf cfg.queueFile} 0700 root root -"
        "d ${cfg.lockDir} 0700 root root -"
      ];

      environment.systemPackages = [
        initHostCache
        pushCurrentSystem
        flushHostCache
        showStatus
      ];

      systemd.services.host-nix-cache-flush = {
        description = "Flush queued Nix binary cache artifacts to the FTPS endpoint";
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        path = [ pkgs.coreutils pkgs.findutils pkgs.gawk pkgs.gnused pkgs.lftp pkgs.nix pkgs.util-linux ];
        script = ''
          exec ${flushHostCache}/bin/host-nix-cache-flush
        '';
      };

      systemd.timers.host-nix-cache-flush = {
        description = "Periodic background flush for queued Nix cache artifacts";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "2min";
          OnUnitActiveSec = cfg.flushInterval;
          Unit = "host-nix-cache-flush.service";
        };
      };
    }
    (mkIf cfg.autoPushBuildOutputs {
      nix.settings."post-build-hook" = "${postBuildHook}";
    })
  ]);
}
