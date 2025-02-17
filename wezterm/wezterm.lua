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
config.color_scheme = "Vs Code Dark+ (Gogh)"
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.use_fancy_tab_bar = true
config.window_frame = {
  font = wezterm.font("JetBrainsMono Nerd Font", { bold = false }),
  font_size = 11,
}

if OS() == "win" then
  config.default_prog = { "pwsh" }
end

config.keys = {
  { key = "F", mods = "CTRL|SHIFT", action = wezterm.action.Search({ CaseInSensitiveString = "" }) },
}

config.colors = {
  tab_bar = {
    active_tab = {
      bg_color = "#1e1e1e",
      fg_color = "#c0c0c0",
    }
  }
}

return config
