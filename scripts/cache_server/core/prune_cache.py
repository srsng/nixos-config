# /// script
# requires-python = ">=3.11"
# ///
"""Prune old cache entries when the LAN cache grows beyond limits.

The script scans .narinfo records, estimates reclaimable size including linked
nar payloads, and removes older entries until the low watermark is reached.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from cache_server_lib import common_parser, human_bytes, load_config, total_size_bytes


@dataclass(slots=True)
class Candidate:
    narinfo_path: Path
    nar_path: Path | None
    narinfo_mtime_ns: int
    reclaimed_bytes: int


def iter_candidates(cache_root: Path):
    for narinfo in sorted(cache_root.glob("*.narinfo")):
        try:
            text = narinfo.read_text(encoding="utf-8", errors="replace")
        except OSError as exc:
            raise RuntimeError(f"Failed to read {narinfo}: {exc}") from exc

        nar_rel = None
        for line in text.splitlines():
            if line.startswith("URL: "):
                nar_rel = line[5:].strip()
                break

        nar_path = (cache_root / nar_rel) if nar_rel else None
        reclaimed = 0
        try:
            reclaimed += narinfo.stat().st_size
            mtime_ns = narinfo.stat().st_mtime_ns
        except OSError as exc:
            raise RuntimeError(f"Failed to stat {narinfo}: {exc}") from exc
        if nar_path and nar_path.exists():
            try:
                reclaimed += nar_path.stat().st_size
            except OSError as exc:
                raise RuntimeError(f"Failed to stat {nar_path}: {exc}") from exc

        yield Candidate(
            narinfo_path=narinfo,
            nar_path=nar_path if nar_path and nar_path.exists() else None,
            narinfo_mtime_ns=mtime_ns,
            reclaimed_bytes=reclaimed,
        )


def delete_candidate(candidate: Candidate, *, dry_run: bool) -> int:
    print(f"Prune candidate: {candidate.narinfo_path.name} reclaim~{human_bytes(candidate.reclaimed_bytes)}")
    if candidate.nar_path is not None:
        print(f"  nar: {candidate.nar_path.relative_to(candidate.narinfo_path.parent)}")
    if dry_run:
        return candidate.reclaimed_bytes

    try:
        candidate.narinfo_path.unlink(missing_ok=False)
        if candidate.nar_path is not None and candidate.nar_path.exists():
            candidate.nar_path.unlink(missing_ok=False)
    except OSError as exc:
        raise RuntimeError(f"Failed to delete cache files for {candidate.narinfo_path}: {exc}") from exc
    return candidate.reclaimed_bytes


def build_parser():
    parser = common_parser("Prune old cache entries when cache_root exceeds the high watermark.")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be deleted and exit.")
    parser.add_argument("--force", action="store_true", help="Run prune scan even if current size is below the high watermark.")
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    config = load_config(args)

    if not config.prune_enabled and not args.force:
        print("Prune is disabled by config; nothing to do.")
        return 0
    if config.prune_order != "oldest-first":
        raise RuntimeError(f"Unsupported prune.order: {config.prune_order!r}")

    current_size = total_size_bytes(config.cache_root)
    print(f"Cache root : {config.cache_root}")
    print(f"Current    : {human_bytes(current_size)}")
    print(f"High/Low   : {human_bytes(config.prune_high_watermark_bytes)} / {human_bytes(config.prune_low_watermark_bytes)}")

    if current_size <= config.prune_high_watermark_bytes and not args.force:
        print("Current cache size is below high watermark; no pruning needed.")
        return 0

    target_size = min(current_size, config.prune_low_watermark_bytes)
    reclaimed = 0
    candidates = sorted(iter_candidates(config.cache_root), key=lambda item: item.narinfo_mtime_ns)
    if not candidates:
        print("No .narinfo entries found; nothing to prune safely.")
        return 0

    for candidate in candidates:
        effective_current = current_size - reclaimed
        if effective_current <= target_size:
            break
        reclaimed += delete_candidate(candidate, dry_run=args.dry_run)

    final_size = current_size - reclaimed if args.dry_run else total_size_bytes(config.cache_root)
    print(f"Reclaimed  : {human_bytes(reclaimed)}")
    print(f"Final est. : {human_bytes(final_size)}")
    if final_size > config.prune_low_watermark_bytes:
        print("WARNING: prune completed but cache is still above low watermark.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
