#!/usr/bin/env bash
# desc: Pokemon colorscripts — random sprite next to fastfetch on shell start (optional eye-candy)
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
# No Fedora package exists, so it is built from the GitLab source (or vendor/).

install_pkgs python3

if need_cmd pokemon-colorscripts; then
  info "pokemon-colorscripts already installed. Skipping..."
else
  SRC="$BUILD_DIR/pokemon-colorscripts"
  git_clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git "$SRC"
  ( cd "$SRC" && run_logged "Installing ${YELLOW}pokemon-colorscripts${RESET} → /opt" sudo -n ./install.sh ) \
    && ok "pokemon-colorscripts installed" || die "pokemon-colorscripts install failed"
fi

# Flip the banner switch in our .zshrc (fastfetch → pokemon + fastfetch)
ZSHRC="$CONFIG_DIR/zsh/.zshrc"
if grep -q '^SHELLSCAPE_BANNER="pokemon"' "$ZSHRC"; then
  info "Banner already set to pokemon"
else
  sed -i 's/^SHELLSCAPE_BANNER=.*/SHELLSCAPE_BANNER="pokemon"/' "$ZSHRC"
  ok "Startup banner → pokemon + fastfetch (SHELLSCAPE_BANNER in config/zsh/.zshrc)"
fi
