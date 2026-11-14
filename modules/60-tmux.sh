#!/usr/bin/env bash
# desc: tmux — terminal multiplexer with Ctrl-a prefix, mouse, Catppuccin status bar, TPM
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

install_pkgs tmux
link_dotfile "$CONFIG_DIR/tmux" "$HOME/.config/tmux"   # tmux ≥3.1 reads ~/.config/tmux/tmux.conf

TPM="$HOME/.tmux/plugins/tpm"
git_clone https://github.com/tmux-plugins/tpm "$TPM"
if [[ -x "$TPM/bin/install_plugins" ]]; then
  run_logged "Installing tmux plugins" "$TPM/bin/install_plugins" \
    && ok "tmux plugins installed" || warn "TPM plugin install failed — press prefix+I inside tmux to retry"
fi
