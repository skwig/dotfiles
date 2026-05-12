# https://scoop.sh/
# Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

winget install Microsoft.Powershell
winget install wezterm
winget install GlazeWM
winget install DEVCOM.JetBrainsMonoNerdFont
winget install nvim
winget install JesseDuffield.lazygit
winget install fastfetch
winget install JanDeDobbeleer.OhMyPosh

winget install fzf
winget install sharkdp.fd
winget install BurntSushi.ripgrep.MSVC
winget install jqlang.jq

scoop bucket add extras
scoop install extras/psfzf
scoop install make
scoop install mingw
}
