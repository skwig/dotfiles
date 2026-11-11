local config_home = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local globals = require(config_home .. "/hypr-custom/hyprland.globals.lua")
local monitors = require(config_home .. "/hypr-custom/hyprland.monitors.lua")(globals)

-- temporary fix until `start-hyprland` is well integrated with uwsm
hl.config({ misc = {
  disable_watchdog_warning = true,
} })

-----------------------------
--- ENVIRONMENT VARIABLES ---
-----------------------------

-- See https://wiki.hyprland.org/Configuring/Environment-variables/

-- Maybe less? Does wlogout respect this value? Maybe it mutliplies it by the scaling factor afterwards
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("QT_CURSOR_SIZE", "24")
hl.env("QT_CURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Adwaita")
hl.env("XDG_SESSION_TYPE", "wayland")

hl.env("GDK_SCALE", tostring(monitors.scale))
-- hl.env("GDK_DPI_SCALE", "1.25")
-- hl.env("QT_SCALE_FACTOR", tostring(monitors.scale))

-----------------
--- AUTOSTART ---
-----------------

-- Lua's start hook replaces exec-once. Unlike that executor queue, ordinary
-- hl.exec_cmd attaches a workspace token. Remove it from each entire command's
-- environment, preserving the five original commands and their shell behavior.
local function exec_once(command)
  local quoted = "'" .. command:gsub("'", "'\\''") .. "'"
  hl.exec_cmd("env -u HL_INITIAL_WORKSPACE_TOKEN sh -c " .. quoted)
end
hl.on("hyprland.start", function()
  exec_once("wl-paste --watch cliphist store &")
  exec_once("systemctl --user start hyprpolkitagent")
  exec_once("vm-submap-on-vm-focus &")
  exec_once("synology-drive &")
  exec_once("sleep 3 && librepods --start-minimized &")
end)

---------------------
--- LOOK AND FEEL ---
---------------------

-- Refer to https://wiki.hyprland.org/Configuring/Variables/

-- https://wiki.hyprland.org/Configuring/Variables/#general
hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,

    border_size = 1,

    -- https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
    col = {
      active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },

    -- Set to true enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = true,

    -- Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
    allow_tearing = false,

    layout = "master",
  },
})

hl.config({ xwayland = {
  enabled = true,
  use_nearest_neighbor = false,
  force_zero_scaling = true,
} })

-- https://wiki.hyprland.org/Configuring/Variables/#decoration
hl.config({
  decoration = {
    rounding = 5,

    active_opacity = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },

    -- https://wiki.hyprland.org/Configuring/Variables/#blur
    blur = {
      enabled = true,
      size = 3,
      passes = 1,

      vibrancy = 0.1696,
    },
  },
})

-- https://wiki.hyprland.org/Configuring/Variables/#animations
hl.config({ animations = {
  enabled = true,
} })

-- Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- original
-- hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
-- hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
-- hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
-- hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
-- hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
-- hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- /2
hl.animation({ leaf = "global", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 2.695, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 2.395, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2.05, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 0.745, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 0.865, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 0.73, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.515, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 1.905, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 0.75, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 0.895, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 0.695, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 0.97, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 0.605, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 0.97, bezier = "almostLinear", style = "fade" })

-- /4
-- hl.animation({ leaf = "global", enabled = true, speed = 2.5, bezier = "default" })
-- hl.animation({ leaf = "border", enabled = true, speed = 1.3475, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "windows", enabled = true, speed = 1.1975, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 1.025, bezier = "easeOutQuint", style = "popin 87%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 0.3725, bezier = "linear", style = "popin 87%" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 0.4325, bezier = "almostLinear" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 0.365, bezier = "almostLinear" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 0.7575, bezier = "quick" })
-- hl.animation({ leaf = "layers", enabled = true, speed = 0.9525, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "layersIn", enabled = true, speed = 1, bezier = "easeOutQuint", style = "fade" })
-- hl.animation({ leaf = "layersOut", enabled = true, speed = 0.375, bezier = "linear", style = "fade" })
-- hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 0.4475, bezier = "almostLinear" })
-- hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 0.3475, bezier = "almostLinear" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 0.485, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesIn", enabled = true, speed = 0.3025, bezier = "almostLinear", style = "fade" })
-- hl.animation({ leaf = "workspacesOut", enabled = true, speed = 0.485, bezier = "almostLinear", style = "fade" })

-- Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ border_size = 0, match = { float = false, workspace = "w[tv1]" } })
-- hl.window_rule({ rounding = 0, match = { float = false, workspace = "w[tv1]" } })
-- hl.window_rule({ border_size = 0, match = { float = false, workspace = "f[1]" } })
-- hl.window_rule({ rounding = 0, match = { float = false, workspace = "f[1]" } })

-- See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
hl.config({
  dwindle = {
    preserve_split = true, -- You probably want this
  },
})

-- See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
hl.config({ master = {
  new_status = "slave",
  mfact = 0.5,
} })

-- https://wiki.hyprland.org/Configuring/Variables/#misc
hl.config({ misc = {
  disable_hyprland_logo = true,
  disable_splash_rendering = true,
} })

-------------
--- INPUT ---
-------------

-- https://wiki.hyprland.org/Configuring/Variables/#input
hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    -- kb_options = "", -- overridden by caps:escape below in the original
    kb_rules = "",
    kb_options = "caps:escape",

    follow_mouse = 2,
    float_switch_override_focus = 0,

    sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

    touchpad = {
      natural_scroll = true,
      scroll_factor = 0.25,
    },
  },
})

-- https://wiki.hyprland.org/Configuring/Variables/#gestures
hl.config({ gestures = {
  workspace_swipe_distance = 400,
} })

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

hl.device({
  name = "imexps/2-generic-explorer-mouse",
  sensitivity = -0.85,
})

-------------------
--- KEYBINDINGS ---
-------------------

require(config_home .. "/hypr/hyprland.keybindings.lua")

local mainMod = "SUPER + ALT"
require(config_home .. "/hypr/hyprland.keybindings.mainMod.lua")(mainMod)

mainMod = "SUPER"
require(config_home .. "/hypr/hyprland.keybindings.mainMod.lua")(mainMod)

------------------------------
--- WINDOWS AND WORKSPACES ---
------------------------------

hl.workspace_rule({ workspace = "1", monitor = monitors.centerMonitor, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = monitors.centerMonitor, persistent = true })
hl.workspace_rule({ workspace = "3", monitor = monitors.centerMonitor, persistent = true })
hl.workspace_rule({ workspace = "4", monitor = monitors.centerMonitor, persistent = true })
hl.workspace_rule({ workspace = "5", monitor = monitors.centerMonitor, persistent = true })
hl.workspace_rule({ workspace = "6", monitor = monitors.leftMonitor })
hl.workspace_rule({ workspace = "7", monitor = monitors.leftMonitor })
hl.workspace_rule({ workspace = "8", monitor = monitors.rightMonitor })
hl.workspace_rule({ workspace = "9", monitor = monitors.rightMonitor })

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({ suppress_event = "maximize", match = { class = ".*" } })

-- Fix some dragging issues with XWayland
hl.window_rule({
  no_focus = true,
  match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
})

require(config_home .. "/hypr/hyprland.apps.lua")

-- Retain the 0.56 default if this config is later used with 0.57.
hl.config({ quirks = { skip_non_kms_dmabuf_formats = false } })
