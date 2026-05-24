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
│   ├── desktop-hyprland.nix
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
``
