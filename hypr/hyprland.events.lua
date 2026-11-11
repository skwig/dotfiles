hl.on("workspace.created", function(workspace)
  if workspace.addressable_name == "special:todo" and workspace.is_empty then
    hl.exec_cmd([[dots-browser --app="https://todo.skwig.party"]], { workspace = "special:todo" })
  end
end)

hl.on("window.active", function(window)
  local is_vm = window and window.mapped and (window.class == ".qemu-system-x86_64-wrapped" or window.class == "Vmware")
  hl.dispatch(hl.dsp.submap(is_vm and "vm" or "reset"))
end)
