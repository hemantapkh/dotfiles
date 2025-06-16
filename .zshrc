# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Antidote
source ${ZDOTDIR:-~}/.antidote/antidote.zsh
antidote load

# Load all .zsh files in the home directory except for .zsh_plugins.zsh
find "$HOME" -maxdepth 1 -name "*.zsh" ! -name ".zsh_plugins.zsh" | while read -r file; do
    source "$file"
done

# Config directory
export XDG_CONFIG_HOME="$HOME/.config"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export ZVM_VI_EDITOR=nvim
export EDITOR="nvim"

# ASDF
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
