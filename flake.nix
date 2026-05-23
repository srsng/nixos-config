{
  description = "srsnn's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/hyprland/v0.55.2";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      hyprland,
      ...
    }:
    let
      lib = nixpkgs.lib;
      myvars = import ./vars/default.nix { inherit lib; };
    in
    {
      nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs myvars; };
        modules = [
          ./hosts/nixos-vm/configuration.nix
        ];
      };
    };
}
