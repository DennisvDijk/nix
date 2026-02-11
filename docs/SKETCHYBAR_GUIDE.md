# SketchyBar Configuration Guide

## 🚫 Important: launchd Integration Removed

Based on [SketchyBar issue #553](https://github.com/FelixKratz/SketchyBar/issues/553), launchd integration does not work properly with SketchyBar. The launchd service has been removed from the configuration.

## 🎯 Recommended SketchyBar Setup

### Option 1: Manual Launch (Recommended)

Add this to your shell configuration (e.g., `.zshrc`):

```bash
# Start SketchyBar if not running
if ! pgrep -x "SketchyBar" > /dev/null; then
  sketchybar > /tmp/sketchybar.log 2>&1 &
  echo "🚀 SketchyBar started"
fi
```

### Option 2: macOS Login Items

1. Open **System Settings** > **General** > **Login Items**
2. Click **+** and add SketchyBar from `/run/current-system/sw/bin/sketchybar`
3. Check "Open at Login"

### Option 3: Use a Script

Create a launch script at `~/.config/sketchybar/launch.sh`:

```bash
#!/usr/bin/env bash

# Kill existing SketchyBar instances
pkill -x SketchyBar

# Wait for cleanup
sleep 1

# Launch SketchyBar
sketchybar > /tmp/sketchybar.log 2>&1 &

echo "SketchyBar launched with PID: $!"
```

Make it executable:
```bash
chmod +x ~/.config/sketchybar/launch.sh
```

## 📁 Configuration Files

All SketchyBar configuration files are managed by Home Manager:

- `~/.config/sketchybar/sketchybarrc` - Main configuration
- `~/.config/sketchybar/workspace_update.sh` - Workspace script

These files are symlinked from the Nix store using `mkStoreOutOfSymlink` for proper permissions.

## 🔧 Configuration Structure

### Darwin Configuration (`modules/shared/services/sketchybar.nix`)

Handles system-level package installation only:

```nix
{
  environment.systemPackages = with pkgs; [
    sketchybar
  ];
  
  # Note: SketchyBar should be launched manually or via login items
  # launchd integration has been removed due to compatibility issues
}
```

### Home Manager Configuration (`modules/shared/home-manager.nix`)

Handles user-level file management:

```nix
{
  # Sketchybar configuration files
  home.file.".config/sketchybar/sketchybarrc" = lib.homeManager.mkStoreOutOfSymlink {
    source = ../config/sketchybar/sketchybarrc;
    executable = true;
  };
  
  home.file.".config/sketchybar/workspace_update.sh" = lib.homeManager.mkStoreOutOfSymlink {
    source = ../config/sketchybar/workspace_update.sh;
    executable = true;
  };
}
```

## 🚀 Launching SketchyBar

### Manual Launch

```bash
# Launch SketchyBar
sketchybar

# Launch with logging
sketchybar > /tmp/sketchybar.log 2>&1 &

# Restart SketchyBar
pkill -x SketchyBar && sketchybar
```

### Debugging

```bash
# View logs
tail -f /tmp/sketchybar.log

# Check if running
pgrep -x SketchyBar

# Kill SketchyBar
pkill -x SketchyBar
```

## 🎯 Workspace Integration

The workspace update script is configured to work with Aerospace:

```bash
# In your Aerospace config (aerospace.toml)
exec-on-workspace-change = ['/bin/bash', '-c',
  'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE'
]
```

## 🔍 Troubleshooting

### SketchyBar Not Starting

1. **Check installation**:
   ```bash
   which sketchybar
   ```

2. **Check logs**:
   ```bash
   tail -f /tmp/sketchybar.log
   ```

3. **Manual launch**:
   ```bash
   sketchybar
   ```

### Configuration Not Loading

1. **Verify file permissions**:
   ```bash
   ls -la ~/.config/sketchybar/
   ```

2. **Check file contents**:
   ```bash
   cat ~/.config/sketchybar/sketchybarrc
   ```

3. **Reload configuration**:
   ```bash
   sketchybar --reload
   ```

### Workspace Updates Not Working

1. **Test workspace script**:
   ```bash
   ~/.config/sketchybar/workspace_update.sh
   ```

2. **Check Aerospace integration**:
   ```bash
   grep "exec-on-workspace-change" ~/.config/aerospace/aerospace.toml
   ```

## 📋 Migration from launchd

If you were previously using the launchd service:

1. **Remove old launchd service**:
   ```bash
   launchctl unload ~/Library/LaunchAgents/com.github.sketchybar.plist 2>/dev/null || true
   rm ~/Library/LaunchAgents/com.github.sketchybar.plist 2>/dev/null || true
   ```

2. **Add to login items** (recommended):
   ```bash
   # Add SketchyBar to login items
   osascript -e 'tell application "System Events" to make login item at end with properties {path:"/run/current-system/sw/bin/sketchybar", hidden:false}'
   ```

3. **Restart your session** for changes to take effect.

## 🎓 Best Practices

1. **Manual launch**: Start SketchyBar after your window manager
2. **Logging**: Always use logging for debugging
3. **Restart**: Use `pkill -x SketchyBar && sketchybar` to restart
4. **Configuration**: Keep configs in `~/.config/sketchybar/`
5. **Permissions**: Ensure scripts are executable

## 📚 Resources

- [SketchyBar GitHub](https://github.com/FelixKratz/SketchyBar)
- [SketchyBar Wiki](https://github.com/FelixKratz/SketchyBar/wiki)
- [Issue #553 - launchd problems](https://github.com/FelixKratz/SketchyBar/issues/553)
- [Aerospace Integration](https://github.com/nikitabobko/AeroSpace)

The SketchyBar configuration is now properly set up without launchd integration, following the recommendations from the official issue tracker.