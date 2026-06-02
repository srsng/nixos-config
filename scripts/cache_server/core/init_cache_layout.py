# /// script
# requires-python = ">=3.11"
# ///
"""Initialize the on-disk layout for the LAN Nix binary cache.

Creates the cache root, the nar/ subdirectory, and optionally a sample
nix-cache-info file so the HTTP cache can be served before any uploads exist.
"""

from __future__ import annotations

from pathlib import Path

from cache_server_lib import common_parser, ensure_dir, format_summary, load_config, write_text_if_missing


def build_parser():
    parser = common_parser("Initialize LAN Nix cache directory layout.")
    parser.add_argument(
        "--create-sample-nix-cache-info",
        dest="create_sample_nix_cache_info",
        action="store_true",
        default=None,
        help="Create nix-cache-info if missing.",
    )
    parser.add_argument(
        "--no-create-sample-nix-cache-info",
        dest="create_sample_nix_cache_info",
        action="store_false",
        help="Do not create nix-cache-info.",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    config = load_config(args)

    ensure_dir(config.cache_root)
    ensure_dir(config.cache_root / "nar")

    created = False
    if config.create_sample_nix_cache_info:
        created = write_text_if_missing(
            config.cache_root / "nix-cache-info",
            "StoreDir: /nix/store\nWantMassQuery: 1\nPriority: 30\n",
        )

    print("Prepared cache server layout:")
    print(f"  Config path     : {config.config_path}")
    print(f"  HTTP cache root : {config.cache_root}")
    print(f"  HTTP nar root   : {config.cache_root / 'nar'}")
    print(f"  HTTP bind       : http://<host-ip>:{config.http_port}/")
    print(f"  FTPS site hint  : {config.ftps_site_root_hint}")
    print(f"  Sample metadata : {'created' if created else 'kept'}")
    print("")
    print("Active configuration:")
    print(format_summary(config))
    print("")
    print("Expected minimum server setup:")
    print("  - HTTP serves the cache root directory.")
    print("  - FTPS points to the same directory (simple LAN mode).")
    print("  - Disable anonymous FTP; use a dedicated upload account.")
    print("  - Limit firewall to LAN only.")
    print("")
    print("If using an FTPS server:")
    print("  - Require SSL on control/data channels.")
    print("  - Open passive port range in firewall.")
    print("  - Ensure .narinfo and nar/ files are readable over HTTP.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
