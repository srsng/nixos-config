{
  description = "srsnn's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/hyprland/v0.55.2";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      hyprland,
      home-manager,
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
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgs;
              users.${myvars.user.name} = import ./home/${myvars.user.name}.nix;
            };
          }
        ];
      };
    };
}
