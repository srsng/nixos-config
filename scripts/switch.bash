#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <host> [local-cache]"
  echo "  local-cache: true|false (default: true)"
  echo "Example: $0 seven-nix"
  echo "Example: $0 seven-nix false"
}

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  usage
  exit 1
fi

host="$1"
local_cache="${2:-true}"

substituters="https://cache.nixos.org/ https://nix-community.cachix.org https://hyprland.cachix.org"
trusted_public_keys="cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="

case "$local_cache" in
  true)
    substituters="http://192.168.31.194:35428 $substituters"
    trusted_public_keys="srsnn-lan-cache-1:LFolmd5ljszL5skFL3X5plj9/D6fkYOKNJJA8mxcdMY= $trusted_public_keys"
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
