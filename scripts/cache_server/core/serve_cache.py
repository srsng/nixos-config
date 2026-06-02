# /// script
# requires-python = ">=3.11"
# ///
"""Serve the cache root over plain HTTP for LAN Nix substituter access.

This script exposes the configured cache directory with Python's built-in
HTTP server and supports dry-run mode for configuration verification.
"""

from __future__ import annotations

import functools
import os
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

from cache_server_lib import common_parser, ensure_dir, format_summary, load_config


class QuietSimpleHandler(SimpleHTTPRequestHandler):
    def log_message(self, format: str, *args):
        super().log_message(format, *args)


def build_parser():
    parser = common_parser("Serve LAN Nix cache over HTTP.")
    parser.add_argument("--dry-run", action="store_true", help="Print resolved command/config and exit.")
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    config = load_config(args)

    ensure_dir(config.cache_root)
    info_file = config.cache_root / "nix-cache-info"
    if not info_file.exists():
        print("WARNING: nix-cache-info not found. Run `just cache init` or push cache content first.")

    print(f"Cache : {config.cache_root}")
    print(f"Listen: {config.http_bind}:{config.http_port}")
    print(f"URL   : http://<host-ip>:{config.http_port}/nix-cache-info")
    print("Resolved configuration:")
    print(format_summary(config))

    if args.dry_run:
        return 0

    handler = functools.partial(QuietSimpleHandler, directory=os.fspath(config.cache_root))
    with ThreadingHTTPServer((config.http_bind, config.http_port), handler) as httpd:
        print("Serving HTTP cache. Press Ctrl+C to stop.")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nStopped HTTP cache server.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
