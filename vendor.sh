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

# pack <name> <source-dir> [tar --exclude=... ]  → vendor/<name>.tar.xz (no .git)
pack() {
  local name=$1 src=$2; shift 2
  if [[ ! -d "$src" ]]; then warn "$name: $src not found (run ./install.sh first) — skipped"; return 0; fi
  run_logged "Packing ${YELLOW}$name${RESET}" \
    tar -cJf "$VENDOR_DIR/$name.tar.xz" -C "$(dirname "$src")" --exclude=.git "$@" "$(basename "$src")" \
    && rm -f "$VENDOR_DIR/$name.tar.gz" \
    && ok "vendor/$name.tar.xz  ($(du -h "$VENDOR_DIR/$name.tar.xz" | cut -f1))"
}

section "Nerd Font"
# The release zip is ~130 MB (too big for GitHub). The 96 TTFs share almost all
# of their glyph data, so a solid xz archive of the same files is ~6 MB.
NF_ZIP="$BUILD_DIR/JetBrainsMono.zip"
NF_TXZ="$VENDOR_DIR/JetBrainsMono.tar.xz"
if [[ -s "$NF_TXZ" && ( ! -s "$NF_ZIP" || "$NF_TXZ" -nt "$NF_ZIP" ) ]]; then
  ok "vendor/JetBrainsMono.tar.xz is up to date ($(du -h "$NF_TXZ" | cut -f1))"
else
  [[ -s "$NF_ZIP" ]] || download "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" "$NF_ZIP"
  NF_TMP="$(mktemp -d)"
  run_logged "Repacking ${YELLOW}JetBrainsMono Nerd Font${RESET} as tar.xz (takes a minute)" \
    bash -c 'unzip -q -o "$1" -d "$3" -x "README*" && tar -cf - -C "$3" . | xz -9 -T0 > "$2"' _ "$NF_ZIP" "$NF_TXZ" "$NF_TMP" \
    && ok "vendor/JetBrainsMono.tar.xz  ($(du -h "$NF_TXZ" | cut -f1))" \
    || die "Font repack failed"
  rm -rf "$NF_TMP"
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
