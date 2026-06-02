# nixos-config

Personal NixOS configuration for the VirtualBox VM `nixos-vm` and the physical `seven-nix` machine.

## Layout

```text
.
├── flake.nix
├── dotfiles/  # some dotfiles from other repo
├── hosts/
│   ├── nixos-vm/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── seven-nix/
│       ├── boot.nix
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/  # public for all host/user
└── home/
    ├── README.md
    └── srsnn/  # some user, check README.md inside home/
```

## Cache Server

LAN cache server commands are available from the repository root:

```text
just cache
just cache help
```

Details live in `scripts/cache_server/README.md`.

## Build/test

Dry build without switching:

```bash
sudo nixos-rebuild --option experimental-features 'nix-command flakes' dry-build --flake ~/nixos-config#seven-nix
```

Apply with the LAN cache first:

```bash
./scripts/switch.bash seven-nix
```

Use `#nixos-vm` instead of `#seven-nix` for the VM host.

## Thanks

dotfiles: github:end-4/dots-hyprland (illogical-impulse)
