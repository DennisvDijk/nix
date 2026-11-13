# Headless Mac mini: Colima (Docker for Hermes) and the Pi coding agent.
# No Homebrew, no GUI apps, no window manager.
{ pkgs, username, ... }:
let
  pi = import ./pi.nix { inherit pkgs; };
in
{
  networking.hostName = "mac-mini";
  system.stateVersion = 6;
  system.primaryUser = username;

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # Determinate Nix, same as the laptops. GC is a LaunchDaemon below
  # because nix.gc.automatic refuses to run when nix.enable is false.
  nix.enable = false;
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Apple's sshd. This is a system daemon, so it is up after reboot
  # without anyone logging into the GUI.
  services.openssh.enable = true;

  power.sleep.computer = "never";
  power.sleep.display = "never";
  power.sleep.harddisk = "never";
  power.restartAfterPowerFailure = true;

  environment.systemPackages = [
    pi
    pkgs.colima
    pkgs.lima
    pkgs.docker-client
    pkgs.git
    pkgs.tmux
  ];

  environment.variables = {
    MINI_ENV = "1";
    DOCKER_HOST = "unix:///Users/${username}/.colima/default/docker.sock";
  };

  # Colima is a Linux VM. On Apple Silicon it uses Virtualization.framework,
  # so there is no Docker Desktop or OrbStack GUI to click.
  # A LaunchDaemon with UserName starts at boot, before a GUI login.
  # OrbStack and Docker Desktop only autostart inside a logged-in session.
  launchd.daemons.colima = {
    path = [
      pkgs.colima
      pkgs.lima
      pkgs.coreutils
    ];
    script = ''
      export HOME=/Users/${username}
      exec colima start --foreground
    '';
    serviceConfig = {
      UserName = username;
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 30;
      StandardOutPath = "/var/log/colima.log";
      StandardErrorPath = "/var/log/colima.log";
      EnvironmentVariables.HOME = "/Users/${username}";
    };
  };

  launchd.daemons.nix-gc = {
    script = ''
      export PATH="/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:$PATH"
      nix-collect-garbage --delete-older-than 14d
      nix-store --optimise
    '';
    serviceConfig = {
      RunAtLoad = false;
      StartCalendarInterval = [
        {
          Hour = 3;
          Minute = 15;
        }
      ];
      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
    };
  };
}
