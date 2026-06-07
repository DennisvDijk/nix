-- WezTerm Configuration
local wezterm = require 'wezterm'
local config = {}

-- Use config builder for better error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Font Configuration with Nerd Font support
config.font = wezterm.font('Hack Nerd Font', { weight = 'Regular' })
config.font_size = 13.0

-- Enable font features for better icon rendering
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Color scheme
config.color_scheme = 'Catppuccin Mocha'

-- Window configuration
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

-- Performance
config.front_end = "WebGpu"

return config
