{
  description = "srsnn's NixOS configuration";

  inputs = {
    # This VM currently runs NixOS 25.11/Xantusia. nixos-unstable tracks that development line.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos-vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/nixos-vm/configuration.nix
        ];
      };
    };
}
