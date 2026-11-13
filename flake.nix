{
  description = "nix-darwin and Home Manager for Dennis van Dijk's Macs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

    # Intentionally not followed. mac-app-util pins nixpkgs for a known-good
    # SBCL and dockutil (see that flake's comment). Following root nixpkgs
    # would rebuild the trampoline against an untested compiler.
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      hosts = import ./lib/hosts.nix { inherit inputs lib; };
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      pkgsFor = system: import inputs.nixpkgs { inherit system; };

      lintSource = lib.fileset.toSource {
        root = ./.;
        fileset = lib.fileset.unions [
          (lib.fileset.fileFilter (file: file.hasExt "nix") ./.)
          ./statix.toml
        ];
      };

      forEach = f: lib.genAttrs systems (system: f (pkgsFor system));

      # Day-to-day commands. `nix run` keeps the caller's working directory,
      # so these operate on the checkout you launched them from.
      app =
        pkgs: name: text:
        let
          bin = pkgs.writeShellScriptBin name text;
        in
        {
          type = "app";
          program = "${bin}/bin/${name}";
          meta.description =
            {
              switch = "darwin-rebuild switch for one host";
              home = "home-manager switch for one host";
              update = "Update flake.lock";
              fmt = "Format Nix files with nixfmt";
              check = "Run deadnix and statix";
            }
            .${name};
        };

      appsFor = pkgs: {
        switch = app pkgs "switch" ''
          set -euo pipefail
          host="''${1:-personal}"
          exec sudo darwin-rebuild switch --flake ".#$host"
        '';
        home = app pkgs "home" ''
          set -euo pipefail
          host="''${1:-personal}"
          exec home-manager switch --flake ".#$host"
        '';
        update = app pkgs "update" ''
          set -euo pipefail
          exec nix flake update
        '';
        fmt = app pkgs "fmt" ''
          set -euo pipefail
          exec nix fmt
        '';
        check = app pkgs "check" ''
          set -euo pipefail
          exec nix flake check
        '';
      };
    in
    {
      inherit (hosts) darwinConfigurations homeConfigurations;

      # nixfmt-tree walks the repo. Plain nixfmt only reads stdin, so
      # `nix fmt` with no paths would do nothing useful.
      formatter = forEach (pkgs: pkgs.nixfmt-tree);

      devShells = forEach (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            just
            nixfmt
            deadnix
            statix
            nil
            nh
            sops
            age
          ];
          shellHook = ''
            echo "nix-config commands: just switch | just home | just all | just update | just fmt | just check"
            echo "Or: nix run .#switch -- <host>    nix run .#home -- <host>"
          '';
        };
      });

      checks = forEach (pkgs: {
        deadnix = pkgs.runCommand "deadnix" { src = lintSource; } ''
          cd "$src"
          ${pkgs.deadnix}/bin/deadnix --fail .
          touch "$out"
        '';
        statix = pkgs.runCommand "statix" { src = lintSource; } ''
          cd "$src"
          ${pkgs.statix}/bin/statix check .
          touch "$out"
        '';
      });

      apps = forEach appsFor;
    };
}
