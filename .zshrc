# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Config directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME=~/.local/share
export XDG_STATE_HOME=~/.local/state
export XDG_CACHE_HOME=~/.cache

autoload -Uz compinit
compinit

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/bin:$PATH"

# Antidote
source ${ZDOTDIR:-~}/.antidote/antidote.zsh
antidote load

# Load all .zsh files in the home directory except for .zsh_plugins.zsh
find "$HOME" -maxdepth 1 -name "*.zsh" ! -name ".zsh_plugins.zsh" | while read -r file; do
    source "$file"
done

# Zoxide
eval "$(zoxide init zsh)"

# Go Path
export PATH="$HOME/go/bin:$PATH"

# Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
source <(kubectl completion zsh)

# Postgres
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/postgresql@18/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@18/include"

# tf
eval $(thefuck --alias)

# ASDF
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Variables
export ZVM_VI_EDITOR="nvim"
export EDITOR="nvim"
export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME/brew/Brewfile"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
