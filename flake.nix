{
  description = "srsnn's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
      system = "x86_64-linux";
      specialArgs = { inherit inputs myvars; };
    in
    {
      nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
        inherit system;
        inherit specialArgs;
        modules = [
          ./hosts/nixos-vm/configuration.nix
        ];
      };
    };
}
