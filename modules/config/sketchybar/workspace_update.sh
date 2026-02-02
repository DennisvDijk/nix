#!/bin/bash

# Update workspace display with app icons
# Called by sketchybar when workspace changes
# Updates ALL workspaces to keep highlighting in sync

focused=$(aerospace list-workspaces --focused)

# Update all 6 workspaces
for sid in {1..6}; do
  # Get apps in this workspace
  apps=$(aerospace list-windows --workspace "$sid" 2>/dev/null | awk -F"|" '{gsub(/^ *| *$/, "", $2); print $2}')

  # Build icon strip
  icon_strip=""
  if [ -n "$apps" ]; then
    while IFS= read -r app; do
      case "$app" in
        "Brave Browser"|"Brave") icon_strip+="🌐 " ;;
        "Google Chrome") icon_strip+="🌐 " ;;
        "Firefox"|"Firefox Nightly") icon_strip+="🦊 " ;;
        "Safari"|"Orion") icon_strip+="🧭 " ;;
        "Code"|"Visual Studio Code"|"VSCode") icon_strip+="💻 " ;;
        "iTerm2"|"iTerm") icon_strip+="⌨️ " ;;
        "Terminal") icon_strip+="⌨️ " ;;
        "Alacritty") icon_strip+="⌨️ " ;;
        "Slack") icon_strip+="💬 " ;;
        "Discord") icon_strip+="💬 " ;;
        "Signal") icon_strip+="💬 " ;;
        "WhatsApp") icon_strip+="💬 " ;;
        "Spotify") icon_strip+="🎵 " ;;
        "Finder") icon_strip+="📁 " ;;
        *) icon_strip+="• " ;;
      esac
    done <<<"$apps"
  fi

  # Highlight active workspace
  if [ "$sid" = "$focused" ]; then
    sketchybar --set space.$sid \
      background.color=0xff89b4fa \
      icon.color=0xff1e1e2e \
      label="$icon_strip"
  else
    sketchybar --set space.$sid \
      background.color=0x44ffffff \
      icon.color=0xffffffff \
      label="$icon_strip"
  fi
done
