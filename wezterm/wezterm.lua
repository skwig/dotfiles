local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

function OS()
  return package.config:sub(1, 1) == "\\" and "win" or "unix"
end

config.font = wezterm.font({
  family = "JetBrainsMono Nerd Font",
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
})
config.font_size = 11
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.color_scheme = "Vs Code Dark+ (Gogh)"
config.window_decorations = "RESIZE"

if OS() == "win" then
  config.default_prog = { "pwsh" }
end

config.keys = {
  { key = "1", mods = "ALT",        action = act.ActivateTab(0) },
  { key = "2", mods = "ALT",        action = act.ActivateTab(1) },
  { key = "3", mods = "ALT",        action = act.ActivateTab(2) },
  { key = "4", mods = "ALT",        action = act.ActivateTab(3) },
  { key = "5", mods = "ALT",        action = act.ActivateTab(4) },
  { key = "6", mods = "ALT",        action = act.ActivateTab(5) },
  { key = "7", mods = "ALT",        action = act.ActivateTab(6) },
  { key = "8", mods = "ALT",        action = act.ActivateTab(7) },
  { key = "9", mods = "ALT",        action = act.ActivateTab(8) },

  { key = "F", mods = "CTRL|SHIFT", action = wezterm.action.Search({ CaseInSensitiveString = "" }) },
}

return config
