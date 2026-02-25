{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    sessionVariables = {
      PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:$PATH";
    };
    
    history = {
      size = 10000;
      share = true;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
    };

    setOptions = [ "AUTOCD" "CORRECT" ];

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "fzf" "vi-mode" ];
    };

    shellAliases = {
      ll = "ls -lah";
      
      # Git aliases
      # Please refer to docs/GIT_ENHANCES.md for documentation about git cmds below
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gap = "git add --patch";
      gau = "git add --update";
      gb = "git branch";
      gba = "git branch -a";
      gbd = "git branch -d";
      gbD = "git branch -D";
      gbl = "git blame";
      gbnm = "git branch --no-merged";
      gbr = "git branch --remote";
      gbs = "git bisect";
      gbsb = "git bisect bad";
      gbsg = "git bisect good";
      gbsr = "git bisect reset";
      gbss = "git bisect start";
      gc = "git commit";
      gca = "git commit --all";
      gcam = "git commit --all --message";
      gcas = "git commit --all --signoff";
      gcb = "git checkout -b";
      gcd = "git checkout develop";
      gcf = "git config --list";
      gcl = "git clone";
      gclean = "git clean -fd";
      gcm = "git checkout main";
      gcmsg = "git commit --message";
      gco = "git checkout";
      gcount = "git shortlog --summary --numbered";
      gcp = "git cherry-pick";
      gcpa = "git cherry-pick --abort";
      gcpc = "git cherry-pick --continue";
      gcs = "git commit --signoff";
      gd = "git diff";
      gdc = "git diff --cached";
      gdct = "git describe --tags";
      gds = "git diff --stat";
      gdt = "git difftool";
      gf = "git fetch";
      gfa = "git fetch --all";
      gfo = "git fetch origin";
      gg = "git gui";
      gga = "git gui citool";
      ggpnp = "git pull origin $(current_branch) && git push origin $(current_branch)";
      ggpup = "git pull origin $(current_branch)";
      ggpush = "git push origin $(current_branch)";
      ggsup = "git branch --set-upstream-to=origin/$(current_branch)";
      ghh = "git help";
      gignore = "git update-index --assume-unchanged";
      git-svn-dcommit-push = "git svn dcommit && git push github master:svntrunk";
      gk = "gitk --all --branches";
      gke = "gitk --all $(git log --walk-reflogs --pretty=%h)";
      gl = "git pull";
      glg = "git log --stat";
      glgg = "git log --graph";
      glgga = "git log --graph --decorate --all";
      glgm = "git log --graph --max-count=10";
      glgp = "git log --graph --pretty='%C(auto)%h%d %s %C(black)%C(bold)%cr %C(reset)%C(green)%an' --stat";
      glo = "git log --oneline --decorate";
      glol = "git log --graph --pretty='%C(auto)%h%d %s %C(black)%C(bold)%cr %C(reset)%C(green)%an' --stat";
      glols = "git log --graph --pretty='%C(auto)%h%d %s %C(black)%C(bold)%cr %C(reset)%C(green)%an' --stat --since";
      glp = "_git_log_pretty";
      gm = "git merge";
      gma = "git merge --abort";
      gmt = "git mergetool";
      gmtvim = "git mergetool --tool=vimdiff";
      gmum = "git merge upstream/master";
      gp = "git push";
      gpd = "git push --dry-run";
      gpf = "git push --force";
      gpoat = "git push origin --all && git push origin --tags";
      gpr = "git pull --rebase";
      gpristine = "git reset --hard && git clean -dfx";
      gpsup = "git push --set-upstream origin $(current_branch)";
      gpu = "git push upstream";
      gpv = "git push -v";
      gr = "git remote";
      gra = "git remote add";
      grb = "git rebase";
      grba = "git rebase --abort";
      grbc = "git rebase --continue";
      grbd = "git rebase develop";
      grbi = "git rebase --interactive";
      grbm = "git rebase master";
      grbs = "git rebase --skip";
      grbv = "git rebase --verbose";
      grev = "git revert";
      grh = "git reset";
      grhh = "git reset --hard";
      grm = "git rm";
      grmc = "git rm --cached";
      grmv = "git remote rename";
      grrm = "git remote remove";
      grs = "git restore";
      grset = "git remote set-url";
      grt = "git restore --staged";
      gru = "git reset --";
      grup = "git remote update";
      grv = "git remote -v";
      gs = "git status";
      gsb = "git status -sb";
      gsd = "git svn dcommit";
      gsi = "git submodule init";
      gsps = "git show --pretty=short --show-signature";
      gsr = "git svn rebase";
      gss = "git status -s";
      gst = "git stash";
      gsta = "git stash apply";
      gstc = "git stash clear";
      gstd = "git stash drop";
      gstl = "git stash list";
      gstp = "git stash pop";
      gsts = "git stash show --text";
      gstu = "git stash -u";
      gstk = "git stash -k";
      gsu = "git submodule update";
      gsw = "git switch";
      gswc = "git switch -c";
      gswd = "git switch develop";
      gswm = "git switch master";
      gswM = "git switch main";
      gta = "git tag -a";
      gtd = "git tag -d";
      gtl = "git tag -l";
      gts = "git tag -s";
      gtv = "git tag -v";
      gunignore = "git update-index --no-assume-unchanged";
      gup = "git pull --rebase";
      gupa = "git pull --rebase --autostash";
      gupav = "git pull --rebase --autostash -v";
      gupv = "git pull --rebase -v";
      
      # SOPS-Nix secrets management
      edit-secrets = "~/.config/nix/bin/edit-secrets.sh";
      esec = "edit-secrets";
      sops-edit = "cd ~/.config/nix && nix-shell -p sops --run 'sops'";
      
      # Telegram shortcuts
      tgsend = "telegram-send";
      tginfo = "telegram-info";
    };

    # Common shell initialization
    initContent = ''
      export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=up:3:hidden:wrap --bind 'ctrl-p:toggle-preview,ctrl-k:up,ctrl-j:down'"
        
      # Starship prompt
      eval "$(starship init zsh)"
        
      # Git helper functions
      function current_branch() {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
      }
      
      function git-info() {
        if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
          echo "📁 $(basename $(git rev-parse --show-toplevel))"
          echo "🌿 $(current_branch)"
          echo "📌 $(git rev-parse --short HEAD)"
          echo "📦 $(git status --porcelain | wc -l | tr -d ' ') changes"
        else
          echo "Not in a git repository"
        fi
      }
      
      function git-sync() {
        local branch="$(current_branch)"
        echo "🔄 Syncing branch: $branch"
        git pull origin "$branch" && git push origin "$branch"
      }
      
      function git-cleanup() {
        echo "🧹 Cleaning up git repository..."
        git remote prune origin && \
        git branch --merged | grep -v "\*" | grep -v master | grep -v main | grep -v develop | xargs -n 1 git branch -d
      }
      
      function git-reset-hard() {
        local branch="$(current_branch)"
        echo "⚠️  Resetting hard to origin/$branch"
        git fetch origin "$branch" && git reset --hard origin/"$branch"
      }
      
      # Smart rebuild functions
      function nix-rebuild() {
        local host=''${NIX_HOST:-personal}
        echo "🔨 Rebuilding darwin system for host: $host"
        sudo darwin-rebuild switch --flake ~/.config/nix#$host
      }
        
      function home-rebuild() {
        local host=''${NIX_HOST:-personal}
        echo "🏠 Rebuilding home-manager for host: $host"
        home-manager switch --flake ~/.config/nix#$host
      }
        
      function nix-full-rebuild() {
        local host=''${NIX_HOST:-personal}
        echo "🚀 Full rebuild for host: $host"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "1️⃣  Darwin system..."
        sudo darwin-rebuild switch --flake ~/.config/nix#$host && \
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" && \
        echo "2️⃣  Home Manager..." && \
        home-manager switch --flake ~/.config/nix#$host && \
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" && \
        echo "✅ Rebuild complete!"
      }
      
      # SOPS secrets management functies
      function sops-new() {
        local secret_name="$1"
        if [ -z "$secret_name" ]; then
          echo "❌ Gebruik: sops-new <naam>"
          echo "Voorbeeld: sops-new database"
          return 1
        fi
        
        local secrets_dir="$HOME/.config/nix/secrets"
        local secret_file="$secrets_dir/''${secret_name}.yaml"
        
        if [ -f "$secret_file" ]; then
          echo "⚠️  Secret bestaat al: $secret_file"
          echo "Gebruik 'edit-secrets $secret_name' om te bewerken"
          return 1
        fi
        
        echo "📝 Nieuwe secret file aanmaken: $secret_file"
        echo "''${secret_name}_key: \"changeme\"" > "$secret_file"
        
        echo "🔐 Versleutelen met sops..."
        cd "$HOME/.config/nix" && nix-shell -p sops --run "sops -e -i \"$secret_file\""
        
        echo "✅ Secret aangemaakt!"
        echo "📝 Bewerk met: edit-secrets $secret_name"
      }
      
      function sops-rekey() {
        echo "🔄 Alle secrets opnieuw versleutelen..."
        cd "$HOME/.config/nix"
        for f in secrets/*.yaml; do
          echo "  🔐 Rekey: $f"
          nix-shell -p sops --run "sops updatekeys \"$f\""
        done
        echo "✅ Rekey voltooid!"
      }
      
      # Telegram helper functies
      function telegram-send() {
        local message="$1"
        local bot_token_file="''${TELEGRAM_BOT_TOKEN_FILE:-$HOME/.config/sops-nix/secrets/telegram_bot_token}"
        local chat_id_file="''${TELEGRAM_CHAT_ID_FILE:-$HOME/.config/sops-nix/secrets/telegram_chat_id}"
        
        if [ -z "$message" ]; then
          echo "❌ Gebruik: telegram-send <bericht>"
          echo "Voorbeeld: telegram-send 'Hallo vanuit Nix!'"
          return 1
        fi
        
        if [ ! -f "$bot_token_file" ]; then
          echo "❌ Telegram bot token niet gevonden: $bot_token_file"
          echo "💡 Deploy eerst: home-manager switch --flake ~/.config/nix#\''${NIX_HOST:-personal}"
          return 1
        fi
        
        local bot_token=$(cat "$bot_token_file")
        local chat_id=$(cat "$chat_id_file")
        
        curl -s -X POST "https://api.telegram.org/bot''${bot_token}/sendMessage" \
          -d "chat_id=''${chat_id}" \
          -d "text=''${message}" \
          -d "parse_mode=Markdown" > /dev/null
        
        if [ $? -eq 0 ]; then
          echo "✅ Bericht verstuurd naar Telegram!"
        else
          echo "❌ Fout bij versturen"
        fi
      }
      
      function telegram-info() {
        local bot_name_file="''${TELEGRAM_BOT_NAME_FILE:-$HOME/.config/sops-nix/secrets/telegram_bot_name}"
        if [ -f "$bot_name_file" ]; then
          echo "🤖 Telegram Bot: $(cat "$bot_name_file")"
        fi
        echo "📁 Token file: ''${TELEGRAM_BOT_TOKEN_FILE:-$HOME/.config/sops-nix/secrets/telegram_bot_token}"
        echo "📁 Chat ID file: ''${TELEGRAM_CHAT_ID_FILE:-$HOME/.config/sops-nix/secrets/telegram_chat_id}"
      }
    '';
  };
};

# fzf, zoxide, direnv are configured in feature modules
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}