function Rider-Fzf { rider $(fzf) }
function Nvim-Fzf { nvim $(fzf) }

Set-Alias rfzf Rider-Fzf
Set-Alias rf Rider-Fzf

Set-Alias nfzf Nvim-Fzf
Set-Alias nf Nvim-Fzf

Set-Alias k kubectl

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
oh-my-posh init pwsh --config "~/dotfiles/powershell/theme.omp.json"| Invoke-Expression

. ~/dotfiles/powershell/completion-kubectl.ps1
