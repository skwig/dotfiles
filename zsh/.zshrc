HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

eval "$(oh-my-posh init zsh --config ~/dotfiles/powershell/theme.omp.json)"
alias ns=nix-search
alias lg=lazygit
