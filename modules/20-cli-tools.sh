#!/usr/bin/env bash
# desc: CLI tools — eza bat fzf zoxide ripgrep fd (aliases wired up in config/zsh/aliases.zsh)
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

install_pkgs eza bat fzf zoxide ripgrep fd-find

for c in eza bat fzf zoxide rg fd; do
  need_cmd "$c" && ok "$c → $(command -v "$c")" || warn "$c not on PATH"
done

# Catppuccin Mocha themes so listings (eza) and file views (bat) match the prompt
link_dotfile "$CONFIG_DIR/eza" "$HOME/.config/eza"
link_dotfile "$CONFIG_DIR/bat" "$HOME/.config/bat"
