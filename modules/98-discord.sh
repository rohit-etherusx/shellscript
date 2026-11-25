#!/usr/bin/env bash
# desc: Discord — Vesktop (Flatpak) whose Shellscape theme CSS is regenerated with every scheme change
# optional
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

install_pkgs flatpak nodejs-npm
# The Discord theme template needs Dart Sass (Fedora's sassc can't compile it).
need_cmd sass || run_logged "Installing ${YELLOW}Dart Sass${RESET} (npm)" sudo -n npm install -g sass
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak info dev.vencord.Vesktop >/dev/null 2>&1 \
  || run_logged "Installing ${YELLOW}Vesktop${RESET} (Flatpak)" flatpak install --user -y flathub dev.vencord.Vesktop

# The CLI writes ~/.config/vesktop/themes/shellscape.theme.css; point that at the Flatpak's config.
FP="$HOME/.var/app/dev.vencord.Vesktop/config/vesktop"
mkdir -p "$FP/themes"
link_dotfile "$FP" "$HOME/.config/vesktop"
note "In Vesktop: Settings → Themes → enable shellscape.theme.css (appears after the next scheme change)."
