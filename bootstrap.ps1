winget install GlazeWM
winget install DEVCOM.JetBrainsMonoNerdFont
winget install nvim

winget install fzf
winget install sharkdp.fd
winget install BurntSushi.ripgrep.MSVC
winget install jqlang.jq

# https://scoop.sh/
# Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop bucket add extras
scoop install extras/psfzf

# https://chocolatey.org/install
choco install mingw
choco install make
