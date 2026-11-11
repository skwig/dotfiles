return function(globals)
    local leftMonitor = "HDMI-A-1"
    local centerMonitor = globals.mainMonitor
    local rightMonitor = "DP-2"
    local scale = 1.25

    hl.monitor({ output = centerMonitor, mode = "highrr", position = "0x0", scale = scale })
    hl.monitor({ output = leftMonitor, mode = "2560x1440@75", position = "auto-left", scale = scale })
    hl.monitor({ output = rightMonitor, mode = "2560x1440@75", position = "auto-right", scale = scale })

    return { leftMonitor = leftMonitor, centerMonitor = centerMonitor, rightMonitor = rightMonitor, scale = scale }
end
