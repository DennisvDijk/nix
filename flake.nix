{
  description = "NixOS configuration for Dennis van Dijk's macOS systems";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, flake-utils, sops-nix, ... }@inputs:
  let
    system = "aarch64-darwin";
    username = "dennisvandijk";
    
    # Helper to create my.* namespace args
    mkMyArgs = hostName: {
      inherit username hostName;
      isDarwin = true;
      isPersonal = hostName == "personal";
      isWork = hostName == "work";
    };
  in
  {
    # Darwin configurations
    darwinConfigurations = builtins.listToAttrs (map (hostName: {
      name = hostName;
      value = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { 
          inherit username inputs;
          my = mkMyArgs hostName;
        };
        modules = [ ./hosts/${hostName}/darwin.nix ];
      };
    }) [ "work" "personal" ]);

    # Home Manager configurations
    homeConfigurations = builtins.listToAttrs (map (hostName: {
      name = hostName;
      value = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.allowUnsupportedSystem = true;
        };
        extraSpecialArgs = { 
          inherit inputs;
          my = mkMyArgs hostName;
        };
        modules = [
          ./hosts/${hostName}/home.nix
          sops-nix.homeManagerModules.sops
        ];
      };
    }) [ "work" "personal" ]);
  };
}
