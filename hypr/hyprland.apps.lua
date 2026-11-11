hl.window_rule({
  name = "todo-workspace",
  match = { workspace = "special:todo" },
  float = true,
  size = "1850 1000",
  center = true,
})

-- Default locations
hl.window_rule({ workspace = "1 silent", match = { class = "brave-browser|google-chrome" } })
hl.window_rule({ workspace = "2 silent", match = { class = "jetbrains-rider" } })
hl.window_rule({ workspace = "3 silent", match = { initial_class = "persistent-terminal" } })
hl.window_rule({ workspace = "5 silent", match = { class = "freelens" } })
hl.window_rule({ workspace = "6 silent", match = { class = "discord" } })
hl.window_rule({ workspace = "6 silent", match = { initial_title = "WebCord" } })

-- bitwarden
hl.window_rule({ no_screen_share = true, match = { class = "^(Bitwarden)$" } })

-- steam
hl.window_rule({ idle_inhibit = "fullscreen", match = { class = "steam" } })

-- runelite
hl.window_rule({ float = true, match = { initial_title = [[^(RuneLite\ Launcher)$]] } })

-- jetbrains
hl.window_rule({ size = "(monitor_w*0.5) (monitor_h*0.5)", match = { class = "(.*jetbrains.*)$", title = "^$" } })

-- hyprshot
hl.layer_rule({ no_anim = true, match = { namespace = "selection" } })

-- hyprpanel
hl.layer_rule({ blur = true, match = { namespace = "wayle-bar-.*" } })
hl.layer_rule({ blur = true, match = { namespace = "bar-.*" } })
hl.layer_rule({ blur = true, match = { namespace = "skwig-dms-bar" } })

-- rofi
hl.layer_rule({ blur = true, match = { namespace = "rofi" } })

-- wlogout
hl.layer_rule({ blur = true, match = { namespace = "logout_dialog" } })

-- VMs
hl.window_rule({
  workspace = "5",
  fullscreen = true,
  idle_inhibit = "always",
  match = { class = [[\.qemu-system-x86_64-wrapped]], title = [[(QEMU\ \(linuxvm-0\).*)]] },
})
hl.window_rule({ workspace = "7", idle_inhibit = "always", match = { class = "Vmware" } })
