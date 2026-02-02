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
    
    # OpenClaw - AI assistant gateway
    nix-openclaw.url = "github:openclaw/nix-openclaw";
    nix-openclaw.inputs.nixpkgs.follows = "nixpkgs";
    
    # sops-nix for secret management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, flake-utils, nix-openclaw, sops-nix, ... }@inputs:
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
        extraSpecialArgs = { inherit inputs; };
        modules = [ 
          ./hosts/${hostName}/home.nix
          sops-nix.homeManagerModules.sops
        ];
      };
    }) [ "work" "personal" ]);
  };
}
