#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
#  Shellscape uninstaller
#    ./uninstall.sh            remove symlinks, restore backups, offer to reset shell to bash
#    ./uninstall.sh --purge    additionally remove Oh-My-Zsh, TPM, pokemon-colorscripts,
#                              the Nerd Font and the dnf packages Shellscape installed
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail
SHELLSCAPE_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
export SHELLSCAPE_DIR
LOG="$SHELLSCAPE_DIR/logs/uninstall-$(date +%Y%m%d-%H%M%S).log"
export LOG
# shellcheck source=lib/common.sh
source "$SHELLSCAPE_DIR/lib/common.sh"

PURGE=0
for a in "$@"; do
  case "$a" in
    --purge) PURGE=1 ;;
    -y|--yes) ASSUME_YES=1 ;;
    -h|--help) sed -n '3,7p' "$0" | sed 's/^#  \{0,1\}//'; exit 0 ;;
    *) die "Unknown option: $a" ;;
  esac
done

section "Removing symlinks"
# Known targets (fallback if links.list is missing) + whatever install recorded
TARGETS=( "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.config/zsh" "$HOME/.config/kitty"
          "$HOME/.config/fastfetch" "$HOME/.config/tmux" "$HOME/.config/eza" "$HOME/.config/bat" )
[[ -f "$LINKS_LIST" ]] && mapfile -t -O "${#TARGETS[@]}" TARGETS <"$LINKS_LIST"
declare -A SEEN
for t in "${TARGETS[@]}"; do
  [[ -n "$t" && -z "${SEEN[$t]:-}" ]] || continue; SEEN[$t]=1
  if [[ -L "$t" && "$(readlink -f "$t")" == "$SHELLSCAPE_DIR"/* ]]; then
    rm "$t"; ok "Removed symlink $t"
  fi
done

DESK="$HOME/.local/share/applications/kitty.desktop"
if grep -qs 'X-Shellscape' "$DESK"; then rm -f "$DESK"; ok "Removed $DESK"; fi

section "Restoring backups"
if [[ -f "$BACKUPS_LIST" ]]; then
  # newest backup per target wins; only restore if the target no longer exists
  tac "$BACKUPS_LIST" | while IFS=$'\t' read -r dst bak; do
    [[ -e "$bak" ]] || continue
    if [[ -e "$dst" || -L "$dst" ]]; then info "Skip $bak ($dst exists)"; continue; fi
    mv "$bak" "$dst"; ok "Restored $dst ← $(basename "$bak")"
  done
else
  info "No backups recorded."
fi

section "Login shell"
ZSH_BIN="$(command -v zsh || true)"
CUR="$(getent passwd "$USER" | cut -d: -f7)"
if [[ -n "$ZSH_BIN" && "$CUR" == "$ZSH_BIN" ]] && ask_yes_no "Reset your login shell to /bin/bash?" y; then
  sudo usermod -s /bin/bash "$USER" && ok "Login shell → /bin/bash"
fi

if [[ $PURGE == 1 ]]; then
  section "Purge"
  for d in "$HOME/.oh-my-zsh" "$HOME/.tmux" "$HOME/.local/share/fonts/JetBrainsMonoNerdFont"; do
    [[ -d "$d" ]] && ask_yes_no "Delete $d?" y && rm -rf "$d" && ok "Deleted $d"
  done
  if [[ -d /opt/pokemon-colorscripts ]] && ask_yes_no "Remove pokemon-colorscripts (/opt)?" y; then
    sudo rm -rf /opt/pokemon-colorscripts /usr/local/bin/pokemon-colorscripts && ok "Removed pokemon-colorscripts"
  fi
  PKGS=(zsh zsh-autosuggestions zsh-syntax-highlighting kitty fastfetch chafa fzf eza bat zoxide ripgrep fd-find tmux)
  if ask_yes_no "dnf remove: ${PKGS[*]} ?" n; then
    sudo dnf remove -y "${PKGS[@]}" 2>&1 | tee -a "$LOG" && ok "Packages removed"
  fi
  fc-cache -f >/dev/null 2>&1 || true
fi

rm -f "$LINKS_LIST" "$BACKUPS_LIST"
echo
ok "Shellscape uninstalled. Log out and back in to complete the shell change."
