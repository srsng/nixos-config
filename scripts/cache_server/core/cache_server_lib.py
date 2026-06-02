# Common helpers for the LAN Nix cache server scripts.
#
# Purpose:
# - Load and normalize TOML configuration shared by all cache-server entry points.
# - Provide common CLI flags, size formatting, and cache directory utility helpers.
# - Keep Python scripts small and callable through the root just cache entrypoint.
#
# Third-party dependencies: none by default.
# If future requirements need extra packages, prefer:
#   uv run --with <package> python <script>.py ...

from __future__ import annotations

import argparse
import contextlib
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any

DEFAULT_CONFIG_NAME = "cache_server.toml"
DEFAULT_CACHE_ROOT = r"H:\caches\nix-cache\binary-cache"
DEFAULT_CREATE_SAMPLE_NIX_CACHE_INFO = True
DEFAULT_BIND = "0.0.0.0"
DEFAULT_PORT = 35428
DEFAULT_MAX_CACHE_BYTES = 200 * 1024 * 1024 * 1024
DEFAULT_LOW_WATERMARK_BYTES = 180 * 1024 * 1024 * 1024
DEFAULT_PRUNE_ORDER = "oldest-first"
DEFAULT_FTPS_NOTE = "Point your FTPS site root to the same cache_root directory."

try:
    import tomllib  # type: ignore[attr-defined]
except ModuleNotFoundError:  # pragma: no cover
    tomllib = None


@dataclass(slots=True)
class Config:
    config_path: Path
    cache_root: Path
    create_sample_nix_cache_info: bool
    http_bind: str
    http_port: int
    max_cache_bytes: int
    prune_enabled: bool
    prune_high_watermark_bytes: int
    prune_low_watermark_bytes: int
    prune_order: str
    ftps_site_root_hint: str


def script_dir() -> Path:
    return Path(__file__).resolve().parent


def default_config_path() -> Path:
    return script_dir() / DEFAULT_CONFIG_NAME


def _parse_toml(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    if tomllib is None:
        raise RuntimeError(
            "Python 3.11+ with tomllib is required to read TOML config. "
            "Please run via uv, or add a tomli fallback if needed."
        )
    with path.open("rb") as f:
        data = tomllib.load(f)
    if not isinstance(data, dict):
        raise RuntimeError(f"Config file must contain a TOML table at top level: {path}")
    return data


def _as_bool(value: Any, *, default: bool) -> bool:
    if value is None:
        return default
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        lowered = value.strip().lower()
        if lowered in {"1", "true", "yes", "on"}:
            return True
        if lowered in {"0", "false", "no", "off"}:
            return False
    raise RuntimeError(f"Expected boolean value, got: {value!r}")


def _as_int(value: Any, *, default: int) -> int:
    if value is None:
        return default
    if isinstance(value, bool):
        raise RuntimeError(f"Expected integer value, got boolean: {value!r}")
    if isinstance(value, int):
        return value
    if isinstance(value, str):
        return int(value.strip())
    raise RuntimeError(f"Expected integer value, got: {value!r}")


def _as_str(value: Any, *, default: str) -> str:
    if value is None:
        return default
    if isinstance(value, str):
        return value
    raise RuntimeError(f"Expected string value, got: {value!r}")


def parse_size_bytes(text: str) -> int:
    raw = text.strip().lower().replace("_", "")
    units = {
        "b": 1,
        "kb": 1000,
        "mb": 1000**2,
        "gb": 1000**3,
        "tb": 1000**4,
        "kib": 1024,
        "mib": 1024**2,
        "gib": 1024**3,
        "tib": 1024**4,
    }
    for unit in sorted(units, key=len, reverse=True):
        if raw.endswith(unit):
            number = raw[: -len(unit)].strip()
            return int(float(number) * units[unit])
    return int(raw)


def human_bytes(value: int) -> str:
    steps = ["B", "KiB", "MiB", "GiB", "TiB"]
    size = float(value)
    for unit in steps:
        if size < 1024.0 or unit == steps[-1]:
            return f"{size:.2f} {unit}"
        size /= 1024.0
    return f"{value} B"


def _merge_cli(raw: dict[str, Any], cli: argparse.Namespace) -> dict[str, Any]:
    merged = dict(raw)
    http_table = dict(merged.get("http") or {})
    limits_table = dict(merged.get("limits") or {})
    prune_table = dict(merged.get("prune") or {})
    ftps_table = dict(merged.get("ftps") or {})

    if getattr(cli, "cache_root", None):
        merged["cache_root"] = cli.cache_root
    if getattr(cli, "create_sample_nix_cache_info", None) is not None:
        merged["create_sample_nix_cache_info"] = cli.create_sample_nix_cache_info

    if getattr(cli, "bind", None):
        http_table["bind"] = cli.bind
    if getattr(cli, "port", None) is not None:
        http_table["port"] = cli.port

    if getattr(cli, "max_cache_bytes", None) is not None:
        limits_table["max_cache_bytes"] = cli.max_cache_bytes

    if getattr(cli, "prune_enabled", None) is not None:
        prune_table["enabled"] = cli.prune_enabled
    if getattr(cli, "prune_high_watermark_bytes", None) is not None:
        prune_table["high_watermark_bytes"] = cli.prune_high_watermark_bytes
    if getattr(cli, "prune_low_watermark_bytes", None) is not None:
        prune_table["low_watermark_bytes"] = cli.prune_low_watermark_bytes
    if getattr(cli, "prune_order", None):
        prune_table["order"] = cli.prune_order

    if getattr(cli, "ftps_site_root_hint", None):
        ftps_table["site_root_hint"] = cli.ftps_site_root_hint

    if http_table:
        merged["http"] = http_table
    if limits_table:
        merged["limits"] = limits_table
    if prune_table:
        merged["prune"] = prune_table
    if ftps_table:
        merged["ftps"] = ftps_table
    return merged


def load_config(cli: argparse.Namespace) -> Config:
    config_path = Path(getattr(cli, "config", None) or default_config_path()).expanduser().resolve()
    raw = _parse_toml(config_path)
    merged = _merge_cli(raw, cli)

    http = merged.get("http") or {}
    limits = merged.get("limits") or {}
    prune = merged.get("prune") or {}
    ftps = merged.get("ftps") or {}

    cache_root = Path(_as_str(merged.get("cache_root"), default=DEFAULT_CACHE_ROOT)).expanduser()
    create_sample = _as_bool(
        merged.get("create_sample_nix_cache_info"),
        default=DEFAULT_CREATE_SAMPLE_NIX_CACHE_INFO,
    )
    http_bind = _as_str(http.get("bind"), default=DEFAULT_BIND)
    http_port = _as_int(http.get("port"), default=DEFAULT_PORT)
    max_cache_bytes = _as_int(limits.get("max_cache_bytes"), default=DEFAULT_MAX_CACHE_BYTES)
    prune_enabled = _as_bool(prune.get("enabled"), default=True)
    prune_high = _as_int(prune.get("high_watermark_bytes"), default=max_cache_bytes)
    prune_low = _as_int(prune.get("low_watermark_bytes"), default=DEFAULT_LOW_WATERMARK_BYTES)
    prune_order = _as_str(prune.get("order"), default=DEFAULT_PRUNE_ORDER)
    ftps_site_root_hint = _as_str(ftps.get("site_root_hint"), default=DEFAULT_FTPS_NOTE)

    if prune_low > prune_high:
        raise RuntimeError(
            f"prune.low_watermark_bytes ({prune_low}) must be <= prune.high_watermark_bytes ({prune_high})"
        )
    if prune_high > max_cache_bytes:
        raise RuntimeError(
            f"prune.high_watermark_bytes ({prune_high}) must be <= limits.max_cache_bytes ({max_cache_bytes})"
        )

    return Config(
        config_path=config_path,
        cache_root=cache_root,
        create_sample_nix_cache_info=create_sample,
        http_bind=http_bind,
        http_port=http_port,
        max_cache_bytes=max_cache_bytes,
        prune_enabled=prune_enabled,
        prune_high_watermark_bytes=prune_high,
        prune_low_watermark_bytes=prune_low,
        prune_order=prune_order,
        ftps_site_root_hint=ftps_site_root_hint,
    )


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def write_text_if_missing(path: Path, content: str) -> bool:
    if path.exists():
        return False
    path.write_text(content, encoding="ascii", newline="\n")
    return True


def total_size_bytes(root: Path) -> int:
    total = 0
    for path in root.rglob("*"):
        with contextlib.suppress(OSError):
            if path.is_file():
                total += path.stat().st_size
    return total


def common_parser(description: str) -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("--config", help="Path to cache_server.toml")
    parser.add_argument("--cache-root", help="Override cache_root")
    parser.add_argument("--bind", help="Override http.bind")
    parser.add_argument("--port", type=int, help="Override http.port")
    parser.add_argument("--max-cache-bytes", type=int, help="Override limits.max_cache_bytes")
    parser.add_argument("--prune-high-watermark-bytes", type=int, help="Override prune.high_watermark_bytes")
    parser.add_argument("--prune-low-watermark-bytes", type=int, help="Override prune.low_watermark_bytes")
    parser.add_argument("--prune-order", help="Override prune.order")
    parser.add_argument("--ftps-site-root-hint", help="Override ftps.site_root_hint")
    return parser


def format_summary(config: Config) -> str:
    return (
        f"config={config.config_path}\n"
        f"cache_root={config.cache_root}\n"
        f"http={config.http_bind}:{config.http_port}\n"
        f"max_cache={human_bytes(config.max_cache_bytes)}\n"
        f"prune={'on' if config.prune_enabled else 'off'} {human_bytes(config.prune_high_watermark_bytes)} -> {human_bytes(config.prune_low_watermark_bytes)}"
    )

