-- Execute the real config against the compositor boundary; never start processes.
local host, fixture = assert(arg[1]), assert(arg[2])
local original_require = require
local loaded, state, submap
local function reset()
    loaded, submap = {}, ""
    state = { settings = {}, env = {}, monitors = {}, devices = {}, gestures = {},
        curves = {}, animations = {}, workspaces = {}, windows = {}, layers = {},
        binds = {}, events = {}, commands = {}, order = {}, sources = {} }
end
local function merge(target, values, prefix)
    for k, v in pairs(values) do
        local name = prefix .. k
        if type(v) == "table" and k ~= "active_border" then
            target[k] = target[k] or {}
            merge(target[k], v, name .. ".")
        else
            target[k] = v
            table.insert(state.order, "setting:" .. name)
        end
    end
end
local function dispatch_factory(name)
    return function(args)
        return function() table.insert(state.calls, { name = name, args = args }) end
    end
end
hl = { dsp = { window = {}, workspace = {} } }
for _, name in ipairs({"exec_cmd", "focus", "submap"}) do hl.dsp[name] = dispatch_factory(name) end
for _, name in ipairs({"close", "float", "pin", "fullscreen", "move", "drag", "resize"}) do
    hl.dsp.window[name] = dispatch_factory("window." .. name)
end
hl.dsp.workspace.toggle_special = dispatch_factory("workspace.toggle_special")
hl.dispatch = function(fn) fn() end
hl.get_active_window = function() return state.active_window end
hl.config = function(values) merge(state.settings, values, "") end
hl.env = function(key, value)
    state.env[key] = value
    table.insert(state.order, "env:" .. key)
end
for api, category in pairs({monitor="monitors", device="devices", gesture="gestures", animation="animations",
        workspace_rule="workspaces", window_rule="windows", layer_rule="layers"}) do
    hl[api] = function(value)
        table.insert(state[category], value)
        table.insert(state.order, category)
    end
end
hl.curve = function(name, value) state.curves[name] = value end
hl.on = function(name, fn)
    assert(not state.events[name], "duplicate event: " .. name)
    state.events[name] = fn
end
hl.exec_cmd = function(command, rules) table.insert(state.commands, {command=command, rules=rules}) end
hl.bind = function(key, action, options)
    state.calls = {}
    action()
    table.insert(state.binds, { key=key, submap=submap, options=options or {}, calls=state.calls })
    table.insert(state.order, "binds")
end
hl.define_submap = function(name, fn)
    local previous = submap
    submap = name
    fn()
    submap = previous
end
require = function(name)
    local path = name
    if not name:match("^/") then path = fixture .. "/hypr/" .. name .. ".lua" end
    local file = io.open(path)
    if not file then return original_require(name) end
    file:close()
    table.insert(state.sources, path:match("([^/]+)$"))
    if loaded[path] == nil then
        local result = assert(loadfile(path))()
        loaded[path] = result == nil and true or result
    end
    return loaded[path]
end
local function load_config()
    reset() -- Hyprland clears user modules, registrations and subscriptions on reload.
    assert(loadfile(fixture .. "/hypr/hyprland.lua"))()
    local event_names = {}
    for name in pairs(state.events) do table.insert(event_names, name) end
    table.sort(event_names)
    state.event_names = event_names
    return state
end
local function exercise_events(snapshot)
    local commands = state.commands
    local function fire(event, ...)
        state.calls, state.commands = {}, {}
        if state.events[event] then state.events[event](...) end
        return { calls=state.calls, commands=state.commands }
    end
    snapshot.event_results = {
        todo_empty = fire("workspace.created", {addressable_name="special:todo", is_empty=true}),
        todo_nonempty = fire("workspace.created", {addressable_name="special:todo", is_empty=false}),
        other_empty = fire("workspace.created", {addressable_name="special:magic", is_empty=true}),
        named_todo = fire("workspace.created", {addressable_name="name:todo", is_empty=true}),
        qemu_focus = fire("window.active", {class=".qemu-system-x86_64-wrapped", mapped=true}),
        vmware_focus = fire("window.active", {class="Vmware", mapped=true}),
        ordinary_focus = fire("window.active", {class="org.wezfurlong.wezterm", mapped=true}),
        empty_focus = fire("window.active", nil),
    }
    -- Hyprland can emit empty focus, followed by the closing, unmapped window.
    snapshot.event_results.close_nil = fire("window.active", nil)
    snapshot.event_results.close_vm = fire("window.active", {class="Vmware", mapped=false})
    snapshot.event_results.close_qemu = fire("window.active", {class=".qemu-system-x86_64-wrapped", mapped=false})
    state.active_window = {class="Vmware", mapped=true}
    snapshot.event_results.reload_vm = fire("config.reloaded")
    state.active_window = {class="Vmware", mapped=false}
    snapshot.event_results.reload_unmapped = fire("config.reloaded")
    state.active_window = {class="org.wezfurlong.wezterm", mapped=true}
    snapshot.event_results.reload_ordinary = fire("config.reloaded")
    state.active_window = nil
    snapshot.event_results.reload_empty = fire("config.reloaded")
    state.commands = commands
end
local first = load_config()
assert(#first.commands == 0, "loading config started a process")
if first.events["hyprland.start"] then first.events["hyprland.start"]() end
exercise_events(first)
first.events, first.calls = nil, nil
local reloaded = load_config()
assert(#reloaded.commands == 0, "reload restarted startup processes")
exercise_events(reloaded)
reloaded.events, reloaded.calls = nil, nil

local function json(value)
    if value == nil then return "null" end
    if type(value) == "string" then
        return '"' .. value:gsub('[%z\1-\31\\"]', function(c)
            if c == '"' then return '\\"' end
            if c == '\\' then return '\\\\' end
            return string.format('\\u%04x', string.byte(c))
        end) .. '"'
    end
    if type(value) ~= "table" then return tostring(value) end
    local result = {}
    if #value > 0 then
        for _, v in ipairs(value) do table.insert(result, json(v)) end
        return "[" .. table.concat(result, ",") .. "]"
    end
    for k, v in pairs(value) do table.insert(result, json(k) .. ":" .. json(v)) end
    return "{" .. table.concat(result, ",") .. "}"
end
print(json({first=first, reloaded=reloaded}))
