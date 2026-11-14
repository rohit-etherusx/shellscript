#!/usr/bin/env bash
# desc: Fonts — Fedora font packages + JetBrainsMono Nerd Font (powerline/icon glyphs)
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

# Base fonts from Fedora's own repos
install_pkgs \
  jetbrains-mono-fonts \
  fira-code-fonts \
  adobe-source-code-pro-fonts \
  google-noto-sans-fonts \
  google-noto-sans-mono-fonts \
  google-noto-emoji-fonts \
  fontawesome-fonts-all \
  || warn "Some font packages were not available (non-fatal)"

# Nerd Font — not packaged in Fedora. Preferred source is the compressed copy in
# vendor/ (6 MB tar.xz, unpacked straight into the font dir); otherwise the
# official release zip is downloaded.
NF_NAME="JetBrainsMono"
NF_DIR="$HOME/.local/share/fonts/${NF_NAME}NerdFont"
NF_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${NF_NAME}.zip"
NF_ZIP="$BUILD_DIR/${NF_NAME}.zip"
NF_TXZ="$VENDOR_DIR/${NF_NAME}.tar.xz"

if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
  info "JetBrainsMono Nerd Font already installed. Skipping..."
else
  mkdir -p "$NF_DIR"
  if [[ -s "$NF_TXZ" ]]; then
    run_logged "Unpacking vendored ${YELLOW}${NF_NAME} Nerd Font${RESET}" tar -xJf "$NF_TXZ" -C "$NF_DIR" \
      && ok "Nerd Font unpacked from vendor/ ($(du -sh "$NF_DIR" | cut -f1))" \
      || die "Could not unpack $NF_TXZ"
  else
    download "$NF_URL" "$NF_ZIP"
    run_logged "Extracting ${YELLOW}${NF_NAME} Nerd Font${RESET}" unzip -o -q "$NF_ZIP" -d "$NF_DIR" -x 'LICENSE*' 'README*' \
      || die "Could not extract $NF_ZIP"
  fi
  run_logged "Rebuilding font cache" fc-cache -f
  if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    ok "JetBrainsMono Nerd Font installed → $NF_DIR"
  else
    die "Nerd Font install failed (fc-list doesn't see it)"
  fi
fi
