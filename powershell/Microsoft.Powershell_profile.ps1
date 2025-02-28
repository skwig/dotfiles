function Rider-Fzf { rider $(fzf) }
function Nvim-Fzf { nvim $(fzf) }
function Wezterm-Start { wezterm start --cwd . }

Set-Alias rfzf Rider-Fzf
Set-Alias rf Rider-Fzf

Set-Alias nfzf Nvim-Fzf
Set-Alias nf Nvim-Fzf

Set-Alias w Wezterm-Start

Set-Alias k kubectl

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
oh-my-posh init pwsh --config "~/dotfiles/powershell/theme.omp.json"| Invoke-Expression

. ~/dotfiles/powershell/completion-kubectl.ps1
