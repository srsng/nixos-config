# nixos-config

Personal NixOS configuration for the VirtualBox VM `nixos-vm`.

## Layout

```text
.
├── flake.nix
├── hosts/
│   └── nixos-vm/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── base.nix
│   ├── desktop-plasma.nix
│   ├── dev.nix
│   ├── ssh.nix
│   └── virtualbox.nix
└── home/
    └── srsnn.nix
```

## Build/test

Dry build without switching:

```bash
sudo nixos-rebuild --option experimental-features 'nix-command flakes' dry-build --flake ~/nixos-config#nixos-vm
```

Apply:

```bash
sudo nixos-rebuild --option experimental-features 'nix-command flakes' switch --flake ~/nixos-config#nixos-vm
```

## Notes

- `/etc/nixos` remains the currently installed system configuration until you explicitly rebuild with this flake.
- Keep host-specific hardware in `hosts/nixos-vm/hardware-configuration.nix`.
- Keep reusable settings in `modules/`.
- This directory has not been initialized as a Git repository yet.
