# Repository task entrypoint.
set windows-shell := ["cmd.exe", "/c"]

_default:
    @just --list
cache command="help":
    @just _cache-{{ command }}
_cache-help:
    @echo LAN Nix binary cache: network push uploads, HTTP clients read back.
    @echo Setup order:
    @echo 1. Edit scripts/cache_server/cache_server.toml for this cache host.
    @echo 2. Run: just cache init
    @echo 3. Point your FTPS server root at cache_root, or any uploader at the same directory.
    @echo 4. Run: just cache serve
    @echo 5. From another machine, run: just cache check
    @echo 6. On a NixOS client, run: just cache push
    @echo Server commands:
    @echo just cache serve-dry-run  Show resolved cache_root, HTTP bind, port, and limits.
    @echo just cache serve          Publish cache_root over HTTP for Nix substituters.
    @echo just cache check          Test that nix-cache-info is reachable over HTTP.
    @echo just cache prune-dry-run  Show whether old .narinfo + nar files would be removed.
    @echo just cache prune          Enforce size limits, default starts above 200GB and stops near 180GB.
    @echo just cache python-check   Syntax-check the Python cache server code.
    @echo NixOS client commands:
    @echo just cache status         Show signing key, FTPS credential, queue, and staging state.
    @echo just cache push           Enqueue the current /run/current-system closure, then flush upload queue.
    @echo Config file: scripts/cache_server/cache_server.toml
    @echo Key idea: cache_root is the upload and HTTP publish boundary.
_cache-init:
    uv run python scripts/cache_server/core/init_cache_layout.py --config scripts/cache_server/cache_server.toml
_cache-serve:
    uv run python scripts/cache_server/core/serve_cache.py --config scripts/cache_server/cache_server.toml
_cache-serve-dry-run:
    uv run python scripts/cache_server/core/serve_cache.py --config scripts/cache_server/cache_server.toml --dry-run
_cache-check:
    uv run python scripts/cache_server/core/check_cache_http.py --config scripts/cache_server/cache_server.toml
_cache-status:
    #!/usr/bin/env sh
    set -eu
    status_cmd=$(command -v host-nix-cache-status || true)
    if [ -z "$status_cmd" ]; then
        echo "host-nix-cache-status not found. Enable hostBinaryCache on this NixOS host and rebuild first." >&2
        exit 1
    fi
    if [ "$(id -u)" -eq 0 ]; then
        "$status_cmd"
    else
        if ! command -v sudo >/dev/null 2>&1; then
            echo "sudo not found; run as root or install sudo." >&2
            exit 1
        fi
        sudo "$status_cmd"
    fi
_cache-push:
    #!/usr/bin/env sh
    set -eu
    push_current_cmd=$(command -v host-nix-cache-push-current-system || true)
    flush_cmd=$(command -v host-nix-cache-flush || true)
    for cmd in host-nix-cache-push-current-system:$push_current_cmd host-nix-cache-flush:$flush_cmd; do
        name=${cmd%%:*}
        path=${cmd#*:}
        if [ -z "$path" ]; then
            echo "$name not found. Enable hostBinaryCache on this NixOS host and rebuild first." >&2
            exit 1
        fi
    done
    if [ "$(id -u)" -eq 0 ]; then
        "$push_current_cmd"
        HOST_NIX_CACHE_FAIL_OPEN=0 "$flush_cmd"
    else
        if ! command -v sudo >/dev/null 2>&1; then
            echo "sudo not found; run as root or install sudo." >&2
            exit 1
        fi
        sudo "$push_current_cmd"
        sudo env HOST_NIX_CACHE_FAIL_OPEN=0 "$flush_cmd"
    fi
_cache-prune:
    uv run python scripts/cache_server/core/prune_cache.py --config scripts/cache_server/cache_server.toml
_cache-prune-dry-run:
    uv run python scripts/cache_server/core/prune_cache.py --config scripts/cache_server/cache_server.toml --dry-run --force
_cache-python-check:
    uv run python -m py_compile scripts/cache_server/core/cache_server_lib.py scripts/cache_server/core/init_cache_layout.py scripts/cache_server/core/serve_cache.py scripts/cache_server/core/check_cache_http.py scripts/cache_server/core/prune_cache.py
