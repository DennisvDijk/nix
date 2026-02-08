# modules/lib/feature-options.nix
# Reusable feature flag helpers for consistent option naming

{ lib, ... }:

let
  inherit (lib) mkEnableOption;
in
{
  # Helper to create my.features.* options with consistent naming
  mkFeatureOption = description: mkEnableOption "Enable ${description}";
  
  # Common feature categories
  features = {
    shell = mkFeatureOption "shell environment (zsh, starship, direnv, zoxide)";
    cli = mkFeatureOption "core CLI tools (fzf, bat, eza, ripgrep, fd)";
    git = mkFeatureOption "Git configuration with aliases and delta";
    nvim = mkFeatureOption "Neovim editor with LSP support";
    terminal = mkFeatureOption "terminal emulators (kitty, wezterm, alacritty)";
    k8s = mkFeatureOption "Kubernetes tools (kubectl, k9s, helm)";
    dev = mkFeatureOption "development tools (docker, node, uv, gh)";
    ai = mkFeatureOption "AI/ML tooling (claude-code, codex, aider)";
    ops = mkFeatureOption "ops/networking tools (nmap, iperf3)";
    darwin = mkFeatureOption "macOS-specific configuration";
    homebrew = mkFeatureOption "Homebrew integration";
    secrets = mkFeatureOption "SOPS secrets management";
  };
}
