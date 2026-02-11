# modules/home/features/git.nix
# Git configuration with modern tooling

{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.my.features.git;
  
  # Get git identity from user config
  gitEmail = if cfg.userEmail != null then cfg.userEmail else config.my.user.email.git;
  gitName = if cfg.userName != null then cfg.userName else config.my.user.fullName;
in
{
  options.my.features.git = {
    enable = mkEnableOption "Git configuration with modern tooling";
    
    userName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Git user name (defaults to my.user.fullName)";
    };
    
    userEmail = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Git user email (defaults to my.user.email.git)";
    };
    
    delta.enable = mkEnableOption "delta for git diff" // { default = true; };
    lazygit.enable = mkEnableOption "lazygit TUI" // { default = true; };
    jujutsu.enable = mkEnableOption "jujutsu VCS" // { default = true; };
    githubCli.enable = mkEnableOption "GitHub CLI" // { default = true; };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      
      # User identity
      userName = gitName;
      userEmail = gitEmail;
      
      # Git settings (new syntax)
      settings = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        push.default = "current";
        core.editor = "nvim";
        core.autocrlf = "input";
        core.fsmonitor = true;
        
        # Reuse recorded resolutions for cleaner rebases
        rerere.enabled = true;
        
        # Better diffs
        diff.algorithm = "histogram";
        diff.colorMoved = "zebra";
        
        # Better merge
        merge.conflictstyle = "zdiff3";
        
        # Better log
        log.decorate = "short";
        
        # URL shortcuts
        url."https://github.com/".insteadOf = "gh:";
        url."git@github.com:".insteadOf = "ghs:";
        
        # Aliases
        alias = {
          # Basic shortcuts
          st = "status -sb";
          ci = "commit";
          co = "checkout";
          br = "branch";
          
          # Enhanced log views
          lg = "log --oneline --graph --decorate";
          lga = "log --oneline --graph --decorate --all";
          lgd = "log --oneline --graph --decorate --since='1 day ago'";
          lgds = "log --oneline --graph --decorate --since='1 week ago'";
          
          # Better diff
          d = "diff";
          ds = "diff --staged";
          dw = "diff --word-diff";
          
          # Stash operations
          ss = "stash save";
          sl = "stash list";
          sp = "stash pop";
          
          # Branch management
          bm = "branch --merged";
          bnm = "branch --no-merged";
          
          # Cleanup
          cleanup = "!git branch --merged | grep -v \\*\\|main\\|master\\|develop | xargs -n 1 git branch -d";
          
          # Fixup commits
          fixup = "commit --fixup";
          squash = "commit --squash";
          
          # Work in progress
          wip = "!git add -A && git commit -m 'WIP: temporary commit'";
          unwip = "reset HEAD~1";
        };
      };
      
      ignores = [
        ".DS_Store"
        "*.swp"
        "*.swo"
        "*~"
        ".env"
        ".env.local"
        ".direnv"
        ".devenv"
        "node_modules"
        ".idea"
        ".vscode"
        "*.log"
        ".zsh_history"
        ".zcompdump*"
      ];
    };

    # Delta as standalone program (new syntax)
    programs.delta = mkIf cfg.delta.enable {
      enable = true;
      enableGitIntegration = true;
      options = {
        line-numbers = true;
        side-by-side = false;
        navigate = true;
        light = false;
        syntax-theme = "catppuccin-mocha";
      };
    };

    programs.lazygit = mkIf cfg.lazygit.enable {
      enable = true;
      settings = {
        gui = {
          theme = {
            activeBorderColor = ["#89b4fa" "bold"];
            inactiveBorderColor = ["#a6adc8"];
            optionsTextColor = ["#89b4fa"];
            selectedLineBgColor = ["#313244"];
            cherryPickedCommitBgColor = ["#45475a"];
            cherryPickedCommitFgColor = ["#89b4fa"];
            unstagedChangesColor = ["#f38ba8"];
            defaultFgColor = ["#cdd6f4"];
          };
        };
        git = {
          paging = {
            colorArg = "always";
            pager = "delta --dark --paging=never";
          };
          commit = {
            signOff = false;
          };
        };
      };
    };

    programs.gh = mkIf cfg.githubCli.enable {
      enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
          prc = "pr create";
          prv = "pr view --web";
        };
      };
      extensions = with pkgs; [
        gh-dash  # Dashboard for PRs and issues
        # gh-copilot - removed from nixpkgs, use 'github-copilot-cli' if needed
      ];
    };

    home.packages = mkIf cfg.jujutsu.enable [ pkgs.jujutsu ];
  };
}
