#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
#  Shellscape vendor.sh — snapshot every non-dnf dependency into vendor/ so the
#  folder can be copied to another machine and ./install.sh needs no GitHub,
#  GitLab or ohmyz.sh access (dnf packages still come from Fedora's repos).
#
#  Run it on a machine where ./install.sh has already completed:
#      ./vendor.sh
#  install.sh then prefers vendor/ automatically and falls back to downloading.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail
SHELLSCAPE_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
export SHELLSCAPE_DIR
LOG="$SHELLSCAPE_DIR/logs/vendor-$(date +%Y%m%d-%H%M%S).log"
export LOG
# shellcheck source=lib/common.sh
source "$SHELLSCAPE_DIR/lib/common.sh"
mkdir -p "$VENDOR_DIR"

# pack <name> <source-dir> [tar --exclude=... ]  → vendor/<name>.tar.gz (no .git)
pack() {
  local name=$1 src=$2; shift 2
  if [[ ! -d "$src" ]]; then warn "$name: $src not found (run ./install.sh first) — skipped"; return 0; fi
  run_logged "Packing ${YELLOW}$name${RESET}" \
    tar -czf "$VENDOR_DIR/$name.tar.gz" -C "$(dirname "$src")" --exclude=.git "$@" "$(basename "$src")" \
    && ok "vendor/$name.tar.gz  ($(du -h "$VENDOR_DIR/$name.tar.gz" | cut -f1))"
}

section "Nerd Font"
if [[ -s "$BUILD_DIR/JetBrainsMono.zip" ]]; then
  cp -u "$BUILD_DIR/JetBrainsMono.zip" "$VENDOR_DIR/" && ok "vendor/JetBrainsMono.zip"
else
  download "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" "$VENDOR_DIR/JetBrainsMono.zip"
fi

section "Oh-My-Zsh + plugins"
OMZ="$HOME/.oh-my-zsh"
pack oh-my-zsh "$OMZ" --exclude='.oh-my-zsh/custom/plugins/zsh-*' --exclude='.oh-my-zsh/cache' --exclude='.oh-my-zsh/log'
pack zsh-autosuggestions     "$OMZ/custom/plugins/zsh-autosuggestions"
pack zsh-syntax-highlighting "$OMZ/custom/plugins/zsh-syntax-highlighting"
[[ -s "$BUILD_DIR/omz-install.sh" ]] && cp -u "$BUILD_DIR/omz-install.sh" "$VENDOR_DIR/" && ok "vendor/omz-install.sh (fallback installer)"

section "tmux"
pack tpm "$HOME/.tmux/plugins/tpm"
note "tmux plugins themselves live in config/tmux/plugins (TPM installs next to tmux.conf) — already portable."

section "pokemon-colorscripts"
SRC="$BUILD_DIR/pokemon-colorscripts"
[[ -d "$SRC" ]] || git_clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git "$SRC"
pack pokemon-colorscripts "$SRC"

section "Result"
du -sh "$VENDOR_DIR"/* | sed "s|$SHELLSCAPE_DIR/||"
echo
ok "vendor/ is $(du -sh "$VENDOR_DIR" | cut -f1). Copy the whole Shellscape folder to a new machine and run ./install.sh"
