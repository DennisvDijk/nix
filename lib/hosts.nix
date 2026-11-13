# Host registry and the flake outputs that build each machine.
# Add a host by adding a row here and creating hosts/<name>/{darwin,home}.nix.
{ inputs, lib }:
let
  system = "aarch64-darwin";

  hosts = {
    personal = {
      username = "dennisvandijk";
    };
    work = {
      username = "Dennis.van.Dijk";
    };
    mac-mini = {
      username = "dennisvandijk";
    };
    template = {
      username = "dennisvandijk";
    };
  };

  mkMy = hostName: username: {
    inherit username hostName;
    isDarwin = true;
    isPersonal = hostName == "personal";
    isWork = hostName == "work";
  };

  specialArgsFor = hostName: cfg: {
    inherit inputs hostName;
    inherit (cfg) username;
    my = mkMy hostName cfg.username;
  };

  darwinConfigurations = lib.mapAttrs (
    hostName: cfg:
    inputs.nix-darwin.lib.darwinSystem {
      inherit system;
      specialArgs = specialArgsFor hostName cfg;
      modules = [ ../hosts/${hostName}/darwin.nix ];
    }
  ) hosts;

  homeConfigurations = lib.mapAttrs (
    hostName: cfg:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.allowUnsupportedSystem = true;
      };
      extraSpecialArgs = (specialArgsFor hostName cfg) // {
        homeDirectory = "/Users/${cfg.username}";
      };
      modules = [
        ../hosts/${hostName}/home.nix
        inputs.sops-nix.homeManagerModules.sops
        inputs.mac-app-util.homeManagerModules.default
      ];
    }
  ) hosts;
in
{
  inherit
    hosts
    system
    darwinConfigurations
    homeConfigurations
    ;
}
