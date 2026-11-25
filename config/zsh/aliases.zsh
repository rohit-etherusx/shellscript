# Shellscape aliases — sourced from .zshrc

# eza (modern ls)
if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias l='eza -l --icons=auto --group-directories-first --git'
  alias la='eza -a --icons=auto --group-directories-first'
  alias lla='eza -la --icons=auto --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons=auto'
fi

# bat
if (( $+commands[bat] )); then
  alias cat='bat --paging=never --style=plain'
  alias catn='command cat'
fi


# Fedora / dnf
alias update='sudo dnf upgrade --refresh'
alias install='sudo dnf install'
alias remove='sudo dnf remove'
alias search='dnf search'

# Misc
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'
alias ff='fastfetch'
alias shellscape-install='"$SHELLSCAPE_DIR/install.sh"'  # `shellscape` itself is the desktop CLI
alias zshrc='${EDITOR:-nano} "$SHELLSCAPE_DIR/config/zsh/.zshrc"'
