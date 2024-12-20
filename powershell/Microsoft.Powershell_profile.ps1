# fzf Ctrl+T and Ctrl+R
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

function Rider-Fzf { rider $(fzf) }

Set-Alias rfzf Rider-Fzf
Set-Alias rf Rider-Fzf

function Nvim-Fzf { nvim $(fzf) }

Set-Alias nfzf Nvim-Fzf
Set-Alias nf Nvim-Fzf