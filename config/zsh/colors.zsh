# Shellscape — Catppuccin Mocha colours for the zsh line editor.
# Sourced from .zshrc AFTER oh-my-zsh.sh (the plugins set their defaults there).

# zsh-autosuggestions: dim grey ghost text
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#585b70'

# zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#585b70'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'
# commands
ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[function]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#a6e3a1'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6e3a1,italic'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#89b4fa,italic'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#cdd6f4'
# options / separators
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#fab387'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#fab387'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#cdd6f4'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#cdd6f4'
# paths — plain text, no underline (clean look); separators slightly pink
ZSH_HIGHLIGHT_STYLES[path]='fg=#89dceb'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#89dceb'
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#f5c2e7'
# quoting
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#cba6f7'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]='fg=#f9e2af'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#f5c2e7'
ZSH_HIGHLIGHT_STYLES[cursor]='fg=#f5e0dc'

# Fedora exports a distro LS_COLORS (/etc/profile.d/colorls.sh) that overrides
# eza's theme.yml. Drop it so ~/.config/eza/theme.yml is authoritative.
# (Oh-My-Zsh already copied it into the completion list-colors above, so tab
# completion keeps its colours; GNU ls falls back to its built-in defaults.)
unset LS_COLORS
