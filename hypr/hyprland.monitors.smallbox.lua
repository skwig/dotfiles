local mainMonitor = "eDP-1"
local leftMonitor = mainMonitor
local centerMonitor = mainMonitor
local rightMonitor = mainMonitor
local scale = 2.0

hl.monitor({ output = centerMonitor, mode = "highrr", position = "0x0", scale = scale })

return { leftMonitor = leftMonitor, centerMonitor = centerMonitor, rightMonitor = rightMonitor, scale = scale }
