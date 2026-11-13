{
  description = "Nix configuration for Dennis van Dijk's Apple Silicon Macs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      sops-nix,
      ...
    }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Per-host username — work laptop has a different macOS account name
      hostUsers = {
        personal = "dennisvandijk";
        work = "Dennis.van.Dijk";
        template = "dennisvandijk";
        mac-mini = "dennisvandijk";
      };

      # Helper to create my.* namespace args
      mkMyArgs =
        hostName:
        let
          username = hostUsers.${hostName};
        in
        {
          inherit username hostName;
          isDarwin = true;
          isPersonal = hostName == "personal";
          isWork = hostName == "work";
        };
    in
    {
      formatter.${system} = pkgs.nixfmt;

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          cachix
          deadnix
          nixd
          nixfmt
          nix-output-monitor
          nix-tree
          statix
        ];
      };

      # Darwin configurations
      darwinConfigurations = builtins.listToAttrs (
        map
          (hostName: {
            name = hostName;
            value = nix-darwin.lib.darwinSystem {
              inherit system;
              specialArgs = {
                username = hostUsers.${hostName};
                inherit hostName inputs;
                my = mkMyArgs hostName;
              };
              modules = [ ./hosts/${hostName}/darwin.nix ];
            };
          })
          [
            "work"
            "personal"
            "template"
            "mac-mini"
          ]
      );

      # Home Manager configurations
      homeConfigurations = builtins.listToAttrs (
        map
          (hostName: {
            name = hostName;
            value = home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs =
                let
                  username = hostUsers.${hostName};
                in
                {
                  inherit inputs username hostName;
                  homeDirectory = "/Users/${username}";
                  my = mkMyArgs hostName;
                };
              modules = [
                ./hosts/${hostName}/home.nix
                sops-nix.homeManagerModules.sops
                inputs.mac-app-util.homeManagerModules.default
              ];
            };
          })
          [
            "work"
            "personal"
            "template"
            "mac-mini"
          ]
      );
    };
}
