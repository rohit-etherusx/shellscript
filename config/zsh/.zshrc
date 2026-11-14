# ──────────────────────────────────────────────────────────────────────────────
#  Shellscape ~/.zshrc  (symlinked from Shellscape/config/zsh/.zshrc)
#  Fedora KDE edition
# ──────────────────────────────────────────────────────────────────────────────

# Where Shellscape lives (resolved through the symlink) — handy for `shellscape` alias
export SHELLSCAPE_DIR="${${(%):-%x}:A:h:h:h}"

# ── PATH ──────────────────────────────────────────────────────────────────────
# Terminals like Ptyxis/Konsole open NON-login shells, so ~/.zprofile is never
# read and ~/.local/bin (claude, pipx, uv tools…) would be missing from PATH.
typeset -U path
path=("$HOME/.local/bin" "$HOME/bin" $path)
export PATH

# ── Oh-My-Zsh ─────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

# shellscape = agnosterzak layout with rounded pill segments + Catppuccin colours.
# Other bundled themes: agnosterzak antares bullet-train
# color-input comfyline emoji fishbone++  — plus every built-in OMZ theme.
ZSH_THEME="shellscape"

plugins=(
    git
    dnf                       # dnfi / dnfu / dnfs ... (Fedora counterpart of the archlinux plugin)
    sudo                      # press Esc twice to prefix the command with sudo
    zsh-autosuggestions
    zsh-syntax-highlighting   # must stay last
)

DISABLE_AUTO_UPDATE="true"    # we don't want OMZ nagging at startup
source "$ZSH/oh-my-zsh.sh"
[[ -f "$HOME/.config/zsh/colors.zsh" ]] && source "$HOME/.config/zsh/colors.zsh"   # Catppuccin for syntax-highlighting/autosuggest

# ── Startup banner ────────────────────────────────────────────────────────────
# fastfetch | pokemon | none      (70-pokemon.sh switches this to "pokemon")
SHELLSCAPE_BANNER="pokemon"
SHELLSCAPE_BANNER_ANIM=1          # 1 = reveal the banner line by line, 0 = instant
SHELLSCAPE_BANNER_DELAY=3         # hundredths of a second between lines

# Print $1 either instantly or line by line (wipe-down animation). Uses zselect
# for the delay so no `sleep` process is forked per line.
shellscape_reveal() {
  if [[ $SHELLSCAPE_BANNER_ANIM == 1 && -t 1 ]] && zmodload zsh/zselect 2>/dev/null; then
    local line
    for line in "${(@f)1}"; do
      print -r -- "$line"
      zselect -t "$SHELLSCAPE_BANNER_DELAY"
    done
  else
    print -r -- "$1"
  fi
}
case "$SHELLSCAPE_BANNER" in
  fastfetch)
    (( $+commands[fastfetch] )) && shellscape_reveal "$(fastfetch -c "$HOME/.config/fastfetch/config-compact.jsonc")" ;;
  pokemon)
    if (( $+commands[pokemon-colorscripts] && $+commands[fastfetch] )); then
      shellscape_reveal "$(pokemon-colorscripts --no-title -s -r | fastfetch -c "$HOME/.config/fastfetch/config-pokemon.jsonc" \
        --logo-type file-raw --logo-height 10 --logo-width 5 --logo -)"
    fi ;;
esac

# ── Tools ─────────────────────────────────────────────────────────────────────
(( $+commands[fzf] ))    && source <(fzf --zsh)              # Ctrl-R history, Ctrl-T files, Alt-C cd
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"        # z <dir>, zi (interactive)
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --color=bg+:#313244,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
(( $+commands[fd] ))     && export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
(( $+commands[bat] ))    && export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# ── History ───────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory sharehistory hist_ignore_dups hist_ignore_space

# ── Aliases ───────────────────────────────────────────────────────────────────
[[ -f "$HOME/.config/zsh/aliases.zsh" ]] && source "$HOME/.config/zsh/aliases.zsh"

# ── Local overrides (not tracked) ─────────────────────────────────────────────
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Make sure the very first prompt doesn't show a ✘ just because the optional
# .zshrc.local test above returned non-zero.
true
