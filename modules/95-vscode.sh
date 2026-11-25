#!/usr/bin/env bash
# desc: VS Code — Shellscape settings/keybinds + extension that recolours VS Code from the wallpaper scheme
# optional
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

if ! need_cmd code; then
  if [[ ! -f /etc/yum.repos.d/vscode.repo ]]; then
    sudo -n rpm --import https://packages.microsoft.com/keys/microsoft.asc
    printf '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n' \
      | sudo -n tee /etc/yum.repos.d/vscode.repo >/dev/null
  fi
  install_pkgs code
fi

warn "Your current VS Code settings.json/keybindings.json are moved to *.bak.<timestamp> (restored by ./uninstall.sh)."
ask_yes_no "Replace VS Code settings with Shellscape's?" n || { note "Skipped VS Code config."; exit 0; }
link_dotfile "$CONFIG_DIR/vscode/settings.json"    "$HOME/.config/Code/User/settings.json"
link_dotfile "$CONFIG_DIR/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
link_dotfile "$CONFIG_DIR/vscode/flags.conf"       "$HOME/.config/code-flags.conf"
run_logged "Installing ${YELLOW}shellscape-vscode-integration${RESET}" \
  code --install-extension "$CONFIG_DIR"/vscode/shellscape-vscode-integration/shellscape-vscode-integration-*.vsix --force \
  && ok "VS Code extension installed — pick the 'Shellscape' colour theme"
