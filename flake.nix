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
  {
    darwinConfigurations = builtins.listToAttrs (map (hostName: {
      name = hostName;
      value = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { username = "dennisvandijk"; };
        modules = [ ./hosts/${hostName}/darwin.nix ];
      };
    }) [ "work" "personal" ]);

    homeConfigurations = builtins.listToAttrs (map (hostName: {
      name = hostName;
      value = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { 
          system = "aarch64-darwin";
          config.allowUnfree = true;
        };
        modules = [ ./hosts/${hostName}/home.nix ];
      };
    }) [ "work" "personal" ]);
  };
}