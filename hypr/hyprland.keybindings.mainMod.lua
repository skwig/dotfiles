return function(mainMod)
  -------------------
  --- KEYBINDINGS ---
  -------------------

  -- Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
  hl.bind(mainMod .. " + A", hl.dsp.exec_cmd([[dots-browser --app="https://chatgpt.com"]]))
  hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("dots-open-webui"))
  hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("dots-browser"))
  hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("dots-launcher"))
  hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd("dots-rider-picker"))
  hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("dots-terminal $EDITOR"))
  hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("dots-terminal"))
  hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("dots-terminal lazydocker"))
  hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("dots-script-picker"))
  hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("dots-start nautilus"))
  hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("dots-terminal yazi"))
  hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
  hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.exec_cmd("skwig-dms-power-menu"))

  hl.bind(mainMod .. " + Delete", hl.dsp.exec_cmd("dots-terminal btop"))
  hl.bind(mainMod .. " + SHIFT + Delete", hl.dsp.exec_cmd("dots-terminal nvtop"))

  hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("dots-terminal --cwd ~/dotfiles/ $EDITOR ."))
  hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd("dots-start bitwarden"))

  hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("dots-cliphist"))

  hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
  hl.bind(mainMod .. " + SHIFT + W", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.pin({ action = "toggle" }))
  end)
  hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

  hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
  hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
  hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
  hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

  hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
  hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
  hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
  hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

  hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
  hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
  hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
  hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
  hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
  hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
  hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
  hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
  hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))

  hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1, follow = false }))
  hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2, follow = false }))
  hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3, follow = false }))
  hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4, follow = false }))
  hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5, follow = false }))
  hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6, follow = false }))
  hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7, follow = false }))
  hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8, follow = false }))
  hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9, follow = false }))

  hl.bind(mainMod .. " + bracketleft", hl.dsp.exec_cmd("dots-focus-left"))
  hl.bind(mainMod .. " + bracketright", hl.dsp.exec_cmd("dots-focus-right"))
  hl.bind(mainMod .. " + SHIFT + bracketleft", hl.dsp.exec_cmd("dots-focus-middle"))
  hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.exec_cmd("dots-focus-middle"))

  hl.bind(mainMod .. " + G", hl.dsp.workspace.toggle_special("magic"))
  hl.bind(mainMod .. " + SHIFT + G", hl.dsp.window.move({ workspace = "special:magic" }))

  hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
  hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

  hl.bind(mainMod .. " + C", hl.dsp.workspace.toggle_special("todo"))

  -- VM
  hl.bind(mainMod .. " + R", hl.dsp.submap("vm"))
  hl.define_submap("vm", function()
    hl.bind(mainMod .. " + R", hl.dsp.submap("reset"))
    hl.bind(mainMod .. " + bracketleft", hl.dsp.exec_cmd("dots-focus-left"))
    hl.bind(mainMod .. " + bracketright", hl.dsp.exec_cmd("dots-focus-right"))
    hl.bind(mainMod .. " + SHIFT + bracketleft", hl.dsp.exec_cmd("dots-focus-middle"))
    hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.exec_cmd("dots-focus-middle"))
    hl.bind(mainMod .. " + C", hl.dsp.workspace.toggle_special("todo"))
  end)
end
