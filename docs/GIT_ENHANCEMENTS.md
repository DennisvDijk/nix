# Git Enhancements for Zsh

## 🎯 Overview

The zsh configuration has been enhanced with comprehensive git aliases and helper functions to improve productivity when working with git repositories.

## 🔧 Git Aliases Added

### Basic Commands
- `g` = `git`
- `ga` = `git add`
- `gaa` = `git add --all`
- `gap` = `git add --patch`
- `gau` = `git add --update`

### Branch Management
- `gb` = `git branch`
- `gba` = `git branch -a` (all branches)
- `gbd` = `git branch -d` (delete)
- `gbD` = `git branch -D` (force delete)
- `gcb` = `git checkout -b` (create branch)
- `gco` = `git checkout`

### Commit Operations
- `gc` = `git commit`
- `gc!` = `git commit --amend`
- `gca` = `git commit --all`
- `gcam` = `git commit --all --message`
- `gcmsg` = `git commit --message`
- `gcs` = `git commit --signoff`

### Diff & Status
- `gd` = `git diff`
- `gdc` = `git diff --cached`
- `gds` = `git diff --stat`
- `gs` = `git status`
- `gsb` = `git status -sb` (short)
- `gss` = `git status -s` (short)

### Fetch & Pull
- `gf` = `git fetch`
- `gfa` = `git fetch --all`
- `gl` = `git pull`
- `gup` = `git pull --rebase`
- `gpr` = `git pull --rebase`

### Push Operations
- `gp` = `git push`
- `gpf` = `git push --force`
- `gpf!` = `git push --force-with-lease`
- `gpsup` = `git push --set-upstream`

### Remote Management
- `gr` = `git remote`
- `gra` = `git remote add`
- `grv` = `git remote -v`
- `grmv` = `git remote rename`
- `grrm` = `git remote remove`

### Stash Operations
- `gst` = `git stash`
- `gsta` = `git stash apply`
- `gstp` = `git stash pop`
- `gstl` = `git stash list`
- `gstd` = `git stash drop`
- `gstc` = `git stash clear`

### Tag Management
- `gta` = `git tag -a` (annotated tag)
- `gtl` = `git tag -l` (list tags)
- `gtd` = `git tag -d` (delete tag)
- `gtv` = `git tag -v` (verify tag)

### Log & History
- `glg` = `git log --stat`
- `glo` = `git log --oneline --decorate`
- `glgg` = `git log --graph`
- `glgga` = `git log --graph --decorate --all`
- `glgp` = `git log --graph --pretty`

### Merge & Rebase
- `gm` = `git merge`
- `gma` = `git merge --abort`
- `grb` = `git rebase`
- `grba` = `git rebase --abort`
- `grbc` = `git rebase --continue`
- `grbi` = `git rebase --interactive`

### Reset & Cleanup
- `grh` = `git reset`
- `grhh` = `git reset --hard`
- `gclean` = `git clean -fd`
- `gpristine` = `git reset --hard && git clean -dfx`

## 🧰 Git Helper Functions

### `current_branch()`
Returns the current git branch name.

**Usage:**
```bash
current_branch
# Output: main
```

**Implementation:**
```bash
function current_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
```

### `git-info()`
Displays comprehensive information about the current git repository.

**Usage:**
```bash
git-info
```

**Output:**
```
📁 repository-name
🌿 current-branch
📌 abc1234
📦 5 changes
```

### `git-sync()`
Pulls and pushes changes for the current branch.

**Usage:**
```bash
git-sync
```

**Implementation:**
```bash
function git-sync() {
  local branch="$(current_branch)"
  echo "🔄 Syncing branch: $branch"
  git pull origin "$branch" && git push origin "$branch"
}
```

### `git-cleanup()`
Cleans up the git repository by pruning remote branches and deleting merged local branches.

**Usage:**
```bash
git-cleanup
```

**Implementation:**
```bash
function git-cleanup() {
  echo "🧹 Cleaning up git repository..."
  git remote prune origin && \
  git branch --merged | grep -v "\*" | grep -v master | grep -v main | grep -v develop | xargs -n 1 git branch -d
}
```

### `git-reset-hard()`
Resets the current branch to match the remote branch exactly.

**Usage:**
```bash
git-reset-hard
```

**Implementation:**
```bash
function git-reset-hard() {
  local branch="$(current_branch)"
  echo "⚠️  Resetting hard to origin/$branch"
  git fetch origin "$branch" && git reset --hard origin/"$branch"
}
```

## 🎯 Usage Examples

### Basic Workflow
```bash
# Navigate to repository
git-info

# Add changes
ga .

# Commit changes
gcmsg "Add new feature"

# Push changes
gp
```

### Branch Management
```bash
# Create new branch
gcb feature/new-feature

# Switch to branch
gco feature/new-feature

# Push with upstream
gpsup
```

### Reviewing Changes
```bash
# Check status
gs

# View diff
gd

# View staged diff
gdc
```

### Syncing with Remote
```bash
# Fetch all
gfa

# Sync current branch
git-sync

# Cleanup
git-cleanup
```

## 💡 Tips & Tricks

### 1. **Tab Completion**
All git aliases support tab completion thanks to the git plugin in Oh My Zsh.

### 2. **Chaining Commands**
```bash
# Add, commit, and push in one line
gaa && gcmsg "Update README" && gp
```

### 3. **Branch Navigation**
```bash
# Quickly switch between branches
gco main
gco develop
gco feature/my-feature
```

### 4. **Log Navigation**
```bash
# View commit history
glo

# View detailed graph
glgga
```

### 5. **Stash Workflow**
```bash
# Stash changes
gst

# Pop stash
gstp

# List stashes
gstl
```

## 📋 Complete Alias Reference

For a complete list of all git aliases, run:
```bash
alias | grep "^g"
```

Or see the configuration in:
`/Users/dennisvandijk/.config/nix/modules/shared/programs/zsh.nix`

## 🔧 Customization

### Adding New Aliases
Add new aliases to the `shellAliases` section:
```nix
shellAliases = {
  # ... existing aliases ...
  gmyalias = "git mycommand --option";
};
```

### Adding New Functions
Add new functions to the `initContent` section:
```nix
initContent = ''
  # ... existing content ...
  
  function my-git-function() {
    echo "Custom git function"
    git some-command
  }
'';
```

## 🎓 Best Practices

1. **Use short aliases** for common commands (e.g., `g`, `ga`, `gc`)
2. **Use descriptive aliases** for complex commands (e.g., `gpsup`, `gpf!`)
3. **Group related commands** (e.g., `gst*` for stash operations)
4. **Use functions** for multi-step operations (e.g., `git-sync`)
5. **Document complex aliases** with comments in the configuration

## 🚀 Productivity Boost

These git enhancements provide:
- **Faster workflow**: Short aliases save typing
- **Consistent interface**: Predictable command patterns
- **Discoverability**: Easy to remember and use
- **Power**: Complex operations simplified
- **Safety**: Force operations require explicit flags

The git configuration is now ready to use and will significantly improve your git workflow productivity!