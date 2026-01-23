{
  description = "NixOS configuration for Dennis van Dijk's macOS systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    # Add flake-utils for better flake patterns
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, flake-utils, ... }@inputs:
  flake-utils.lib.eachDefaultSystem (system:
    let
      username = "dennisvandijk";
      
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Helper to create a darwin configuration for a host
      mkDarwinConfig = hostName: nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit username; };
        modules = [
          # Host-specific darwin config (contains all settings)
          ./hosts/${hostName}/darwin.nix
          # Home Manager integration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./hosts/${hostName}/home.nix;
          }
        ];
      };

    in
    {
      darwinConfigurations = {
        work = mkDarwinConfig "work";
        personal = mkDarwinConfig "personal";
      };

      homeConfigurations = {
        work = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./hosts/work/home.nix ];
        };
        personal = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./hosts/personal/home.nix ];
        };
      };
    }
  );
}