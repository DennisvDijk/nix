# Starting point for a new Mac.
# `modules/darwin/common.nix` brings in user, caches, and the Homebrew baseline.
#
# This host used to import modules/shared/darwin.nix, which did not evaluate
# (`my.*` was not defined, and `hostName` was not passed in). The package and
# cask lists from that file are preserved below so nothing listed there is
# dropped. Where the two files disagreed, this host's own settings win:
# nix.enable stays false (Determinate Nix) and Homebrew cleanup stays off.
{ pkgs, lib, ... }:
{
  imports = [ ../../modules/darwin/common.nix ];

  my.darwin.homebrew.brews.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.package = pkgs.nixVersions.stable;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  homebrew.brews = lib.mkAfter [
    "ffmpeg"
    "supabase/tap/supabase"
    "yt-dlp"
    "anomalyco/tap/opencode"
    "pi-coding-agent"
  ];

  homebrew.taps = lib.mkAfter [
    "supabase/tap"
    "anomalyco/tap"
  ];

  homebrew.casks = lib.mkAfter [
    "spotify"
    "whatsapp"
    "ollama"
    "signal"
    "orion"
    "tailscale-app"
    "lm-studio"
    "llamabarn"
    "wave"
    "parsec"
    "blender"
    "emdash"
  ];

  environment.systemPackages = with pkgs; [
    home-manager
    git
    chatgpt
    discord
    podman
    sketchybar
    wezterm
    alacritty
    k9s
    telegram-desktop
    gnupg
  ];
}
