# /// script
# requires-python = ">=3.11"
# ///
"""Check that the HTTP cache endpoint is readable and minimally valid.

Fetches nix-cache-info, verifies required metadata, and optionally warns if the
root listing does not currently expose the nar/ directory.
"""

from __future__ import annotations

from urllib.error import URLError, HTTPError
from urllib.request import urlopen

from cache_server_lib import common_parser, load_config


def build_parser():
    parser = common_parser("Check the HTTP nix-cache-info endpoint.")
    parser.add_argument("--url", help="Explicit nix-cache-info URL to check.")
    parser.add_argument("--allow-missing-nar", action="store_true", help="Do not warn if root listing lacks nar/.")
    return parser


def fetch_text(url: str) -> str:
    try:
        with urlopen(url, timeout=10) as response:
            status = getattr(response, "status", None) or response.getcode()
            if status != 200:
                raise RuntimeError(f"Unexpected HTTP status: {status}")
            return response.read().decode("utf-8", errors="replace")
    except HTTPError as exc:
        raise RuntimeError(f"Failed to fetch {url}: HTTP {exc.code}") from exc
    except URLError as exc:
        raise RuntimeError(f"Failed to fetch {url}: {exc.reason}") from exc


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    config = load_config(args)

    url = args.url or f"http://127.0.0.1:{config.http_port}/nix-cache-info"
    body = fetch_text(url)

    if "StoreDir: /nix/store" not in body:
        raise RuntimeError("nix-cache-info is missing StoreDir: /nix/store")
    if ("WantMassQuery:" not in body) or ("Priority:" not in body):
        print("WARNING: nix-cache-info is missing WantMassQuery or Priority; metadata may be incomplete.")

    print("HTTP cache endpoint looks healthy.")
    print(f"Checked: {url}")

    root_url = url[: -len("nix-cache-info")]
    try:
        index = fetch_text(root_url)
        if "nar/" not in index and not args.allow_missing_nar:
            print("WARNING: Root listing does not show nar/; confirm static file server exposes the nar directory.")
    except Exception as exc:
        print(f"WARNING: Fetched nix-cache-info successfully, but root listing check failed: {exc}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
