#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <host> [cache-mode]"
  echo "  cache-mode: true|false|lan-only (default: true)"
  echo "Example: $0 seven-nix"
  echo "Example: $0 seven-nix lan-only"
  echo "Example: $0 seven-nix false"
}

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  usage
  exit 1
fi

host="$1"
cache_mode="${2:-true}"
lan_cache="http://192.168.31.194:35428"
lan_cache_key="srsnn-lan-cache-1:LFolmd5ljszL5skFL3X5plj9/D6fkYOKNJJA8mxcdMY="

substituters="https://cache.nixos.org/ https://nix-community.cachix.org https://hyprland.cachix.org"
trusted_public_keys="cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="

case "$cache_mode" in
  true)
    substituters="$lan_cache $substituters"
    trusted_public_keys="$lan_cache_key $trusted_public_keys"
    ;;
  lan-only)
    substituters="$lan_cache"
    trusted_public_keys="$lan_cache_key"
    ;;
  false)
    ;;
  *)
    usage
    exit 1
    ;;
esac

sudo nixos-rebuild switch --flake "$HOME/nixos-config#$host" \
  --option extra-experimental-features "nix-command flakes" \
  --option substituters "$substituters" \
  --option trusted-public-keys "$trusted_public_keys"
