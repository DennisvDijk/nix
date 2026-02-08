# modules/home/features/k8s.nix
# Kubernetes and cloud-native tooling

{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.my.features.k8s;
in
{
  options.my.features.k8s = {
    enable = mkEnableOption "Kubernetes and cloud-native tools";
    
    kubectl.enable = mkEnableOption "kubectl" // { default = true; };
    k9s.enable = mkEnableOption "k9s TUI" // { default = true; };
    helm.enable = mkEnableOption "Helm package manager" // { default = true; };
    operators.enable = mkEnableOption "Kubernetes operators" // { default = true; };
    cloud.enable = mkEnableOption "Cloud CLIs (AWS, GCP, Azure)" // { default = false; };
  };

  config = mkIf cfg.enable {
    home.packages = mkMerge [
      (mkIf cfg.kubectl.enable (with pkgs; [
        kubectl
        kubectx             # Context and namespace switching (includes kubens)
        stern               # Multi-pod log tailing
        
        # Kubernetes utilities
        kubectl-tree        # Tree view of resources
        kubectl-neat        # Clean up YAML
        kubectl-cnpg        # CloudNativePG plugin
        
        # Alternative tools
        k3d                 # k3s in Docker
        kind                # Kubernetes in Docker
      ]))
      
      (mkIf cfg.k9s.enable (with pkgs; [
        k9s                 # Kubernetes TUI
      ]))
      
      (mkIf cfg.helm.enable (with pkgs; [
        kubernetes-helm
        helmfile            # Declarative Helm deployments
      ]))
      
      (mkIf cfg.operators.enable (with pkgs; [
        # Operators and controllers
        operator-sdk
        kustomize           # Kubernetes native config management
        
        # GitOps
        fluxcd              # GitOps toolkit
        argocd              # ArgoCD CLI
      ]))
      
      (mkIf cfg.cloud.enable (with pkgs; [
        # Cloud CLIs
        awscli2
        google-cloud-sdk
        azure-cli
        
        # Cloud tools
        s3cmd
        s5cmd               # Faster S3 operations
        
        # Secrets
        sops
        age
      ]))
    ];

    # Kubernetes shell integration
    programs.zsh.initExtra = ''
      # kubectl completion
      if command -v kubectl &>/dev/null; then
        eval "$(kubectl completion zsh)"
        alias k='kubectl'
        alias kg='kubectl get'
        alias kd='kubectl describe'
        alias kdel='kubectl delete'
        alias ka='kubectl apply -f'
        alias kx='kubectx'
        alias kn='kubens'
      fi
      
      # k9s config directory
      export K9S_CONFIG_DIR="$HOME/.config/k9s"
    '';

    # k9s config (if using Catppuccin theme)
    xdg.configFile."k9s/config.yaml" = mkIf cfg.k9s.enable {
      text = builtins.toJSON {
        k9s = {
          liveViewAutoRefresh = true;
          screenDumpDir = "${config.home.homeDirectory}/.local/state/k9s/screen-dumps";
          refreshRate = 2;
          maxConnRetry = 5;
          readOnly = false;
          noExitOnCtrlC = false;
          ui = {
            enableMouse = true;
            headless = false;
            logoless = false;
            crumbsless = false;
            noIcons = false;
            skin = "catppuccin-mocha";
          };
          skipLatestRevCheck = false;
          disablePodCounting = false;
        };
      };
    };
  };
}
