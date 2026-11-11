return function(globals)
    local leftMonitor = globals.mainMonitor
    local centerMonitor = globals.mainMonitor
    local rightMonitor = globals.mainMonitor
    local scale = 2.0

    hl.monitor({ output = centerMonitor, mode = "highrr", position = "0x0", scale = scale })

    return { leftMonitor = leftMonitor, centerMonitor = centerMonitor, rightMonitor = rightMonitor, scale = scale }
end
