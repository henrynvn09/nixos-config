{
  description = "Henry's multi-host dotfiles and system configurations (macOS & Linux)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, sops-nix, ... }@inputs:
    let
      darwinSystem = "aarch64-darwin";
      linuxSystem = "x86_64-linux";
    in
    {
      # macOS system configurations (nix-darwin)
      darwinConfigurations = {
        "Henrys-MacBook-Pro" = nix-darwin.lib.darwinSystem {
          system = darwinSystem;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/macbook
            home-manager.darwinModules.home-manager
          ];
        };

        # Convenience alias
        "macbook" = self.darwinConfigurations."Henrys-MacBook-Pro";
      };

      # NixOS system configurations
      nixosConfigurations = {
        "nixos" = nixpkgs.lib.nixosSystem {
          system = linuxSystem;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/nixos
            home-manager.nixosModules.home-manager
          ];
        };
      };

      # Standalone Home Manager configuration (for generic Linux / servers)
      homeConfigurations = {
        "henry" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${linuxSystem};
          extraSpecialArgs = { inherit inputs; };
          modules = [
            ./modules/home
          ];
        };
      };
    };
}
