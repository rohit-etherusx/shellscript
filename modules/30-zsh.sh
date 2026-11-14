#!/usr/bin/env bash
# desc: Zsh — zsh + Oh-My-Zsh + autosuggestions/syntax-highlighting + shellscape/agnosterzak themes, set as default shell
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"
# Mirrors Arch-Hyprland/install-scripts/zsh.sh

install_pkgs zsh zsh-autosuggestions zsh-syntax-highlighting

ZSH_SRC="$CONFIG_DIR/zsh"
OMZ="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-$OMZ/custom}"

# 1. Link our dotfiles FIRST so the OMZ installer (--keep-zshrc) leaves them alone
link_dotfile "$ZSH_SRC/.zshrc"    "$HOME/.zshrc"
link_dotfile "$ZSH_SRC/.zprofile" "$HOME/.zprofile"
link_dotfile "$ZSH_SRC"           "$HOME/.config/zsh"

# 2. Oh-My-Zsh (unattended, don't touch .zshrc, don't chsh, don't launch zsh)
if [[ -d "$OMZ" ]]; then
  info "Oh-My-Zsh already installed. Skipping..."
elif vendor_extract oh-my-zsh "$OMZ"; then
  :   # offline copy from vendor/
else
  download "https://install.ohmyz.sh" "$BUILD_DIR/omz-install.sh"
  run_logged "Installing ${YELLOW}Oh-My-Zsh${RESET}" \
    env RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh "$BUILD_DIR/omz-install.sh" --unattended --keep-zshrc \
    && ok "Oh-My-Zsh installed" || die "Oh-My-Zsh install failed"
fi

# 3. Plugins (same two the Arch repo clones)
mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"
git_clone https://github.com/zsh-users/zsh-autosuggestions     "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git_clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# 4. Extra themes from Arch-Hyprland/assets/add_zsh_theme (agnosterzak is the default)
cp -f "$ZSH_SRC"/themes/*.zsh-theme "$ZSH_CUSTOM/themes/"
ok "Installed $(ls "$ZSH_SRC"/themes/*.zsh-theme | wc -l) themes → $ZSH_CUSTOM/themes"

# 5. Default shell
ZSH_BIN="$(command -v zsh)"
grep -qxF "$ZSH_BIN" /etc/shells || echo "$ZSH_BIN" | sudo -n tee -a /etc/shells >/dev/null
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
if [[ "$CURRENT_SHELL" == "$ZSH_BIN" ]]; then
  info "Default shell is already zsh."
elif ask_yes_no "Set zsh as your default login shell?" y; then
  sudo -n usermod -s "$ZSH_BIN" "$USER" && ok "Default shell → zsh (takes effect at next login)"
else
  note "Skipped chsh. Run later:  chsh -s $ZSH_BIN"
fi
