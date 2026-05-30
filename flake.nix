{
  description = "srsnn's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/hyprland/v0.55.2";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "github:quickshell-mirror/quickshell/7d1c9a9c6721606b129829134d6f614f015621e2";
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
      myvars = import ./vars { inherit lib; };
      mylib = import ./lib { inherit lib myvars; };

      system = "x86_64-linux";
      specialArgs = { inherit inputs myvars mylib; };
      mkHost = hostName:
        nixpkgs.lib.nixosSystem {
          inherit system;
          inherit specialArgs;
          modules = [
            ./hosts/${hostName}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = specialArgs;
                users.${myvars.user.name} = import ./home/${myvars.user.name};
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        nixos-vm = mkHost "nixos-vm";
        seven-nix = mkHost "seven-nix";
      };
    };
}
