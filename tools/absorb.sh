#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
#  tools/absorb.sh — import the Caelestia (Fedora fork) desktop into Shellscape
#  and rebrand it.
#
#  Upstream clones are expected NEXT TO the Shellscape folder:
#    ../caelestia-fedora        dotfiles (hypr, foot, fish, starship, btop, ...)
#    ../caelestia-fedora-shell  Quickshell desktop shell (QML)
#    ../caelestia-fedora-cli    Python CLI (themes, wallpapers, screenshots, ...)
#
#  Usage:  tools/absorb.sh [UPSTREAM_PARENT_DIR]
#
#  WARNING: re-running overwrites desktop/ and the imported config/ dirs with a
#  fresh rebranded copy. Shellscape is a git repo, so use `git diff` afterwards
#  to re-apply local Fedora fixes (they are kept as separate commits/patches).
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail
ROOT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
UP="$(cd "${1:-$ROOT/..}" && pwd)"
DOTS="$UP/caelestia-fedora" SHELL_SRC="$UP/caelestia-fedora-shell" CLI_SRC="$UP/caelestia-fedora-cli"
for d in "$DOTS" "$SHELL_SRC" "$CLI_SRC"; do [[ -d "$d" ]] || { echo "missing upstream clone: $d" >&2; exit 1; }; done

# copy <src> <dst>  → fresh copy without VCS / Nix / GitHub-meta files
copy() {
  rm -rf "$2"; mkdir -p "$(dirname "$2")"
  cp -a "$1" "$2"
  rm -rf "$2"/.git "$2"/.github "$2"/flake.nix "$2"/flake.lock "$2"/default.nix "$2"/nix "$2"/result
}

# 1. Desktop shell + CLI → desktop/
copy "$SHELL_SRC" "$ROOT/desktop/shell"
copy "$CLI_SRC"   "$ROOT/desktop/cli"
rm -f "$ROOT/desktop/cli/run.sh"   # Nix dev helper

# 2. App configs → config/  (fastfetch is merged, not replaced: Shellscape keeps its own layouts)
IMPORTED=(hypr foot fish uwsm btop qt5ct qt6ct micro zed thunar firefox spicetify vscode zen)
for d in "${IMPORTED[@]}"; do copy "$DOTS/$d" "$ROOT/config/$d"; done
cp "$DOTS/starship.toml" "$ROOT/config/starship.toml"
cp "$DOTS/fastfetch/saturn.txt" "$ROOT/config/fastfetch/saturn.txt"
cp "$DOTS/fastfetch/config.jsonc" "$ROOT/config/fastfetch/config-saturn.jsonc"

# 3. Record exactly what was imported
{
  echo "# Imported by tools/absorb.sh on $(date -I)"
  for d in "$DOTS" "$SHELL_SRC" "$CLI_SRC"; do
    printf '%-24s %s %s\n' "$(basename "$d")" "$(git -C "$d" rev-parse --short HEAD)" "$(git -C "$d" remote get-url origin)"
  done
} > "$ROOT/desktop/UPSTREAM"

# 4. Rebrand caelestia → shellscape in every imported text file.
#    Kept on purpose (external contracts / credits):
#      caelestia-dots, EnceladusII/caelestia-fedora*  → upstream credit URLs
#      caelestiafox, CaelestiaFox, @caelestia.org     → published Firefox add-on + its native-messaging id
TARGETS=("$ROOT/desktop/shell" "$ROOT/desktop/cli" "$ROOT/config/starship.toml" "$ROOT/config/fastfetch/config-saturn.jsonc")
for d in "${IMPORTED[@]}"; do TARGETS+=("$ROOT/config/$d"); done

mapfile -t FILES < <(grep -rIl -i caelestia "${TARGETS[@]}" || true)
for f in "${FILES[@]}"; do
  sed -i \
    -e 's#caelestia-dots#@@KEEP_DOTS@@#g' \
    -e 's#EnceladusII/caelestia-fedora#@@KEEP_FORK@@#g' \
    -e 's#caelestiafox#@@KEEP_FOX@@#g; s#CaelestiaFox#@@KEEP_FOXN@@#g; s#@caelestia\.org#@@KEEP_ORG@@#g' \
    -e 's#CAELESTIA#SHELLSCAPE#g; s#Caelestia#Shellscape#g; s#caelestia#shellscape#g' \
    -e 's#@@KEEP_DOTS@@#caelestia-dots#g; s#@@KEEP_FORK@@#EnceladusII/caelestia-fedora#g' \
    -e 's#@@KEEP_FOX@@#caelestiafox#g; s#@@KEEP_FOXN@@#CaelestiaFox#g; s#@@KEEP_ORG@@#@caelestia.org#g' \
    "$f"
done

# 5. Rename files/dirs containing "caelestia" (deepest first), except the add-on ids.
find "${TARGETS[@]}" -depth -name '*caelestia*' ! -name '*caelestiafox*' | while read -r p; do
  mv "$p" "$(dirname "$p")/$(basename "$p" | sed 's/caelestia/shellscape/g')"
done

# 6. The prebuilt VS Code extension is a zip: rebrand its contents and repack it.
VSIX_DIR="$ROOT/config/vscode/shellscape-vscode-integration"
for v in "$VSIX_DIR"/*.vsix; do
  [[ -f "$v" ]] || continue
  tmp="$(mktemp -d)"; unzip -q "$v" -d "$tmp"
  grep -rIl -i caelestia "$tmp" | xargs -r sed -i 's#CAELESTIA#SHELLSCAPE#g; s#Caelestia#Shellscape#g; s#caelestia#shellscape#g'
  find "$tmp" -depth -name '*caelestia*' | while read -r p; do mv "$p" "$(dirname "$p")/$(basename "$p" | sed 's/caelestia/shellscape/g')"; done
  rm -f "$v"; (cd "$tmp" && zip -q -r -X "$v" .)
  rm -rf "$tmp"
done

# 7. Self-check: nothing branded "caelestia" may remain except the kept identifiers.
LEFT="$(grep -rIn -i caelestia "${TARGETS[@]}" | grep -v -E 'caelestia-dots|EnceladusII/caelestia-fedora|caelestiafox|CaelestiaFox|@caelestia\.org' || true)"
if [[ -n "$LEFT" ]]; then echo "Unexpected leftovers:" >&2; echo "$LEFT" >&2; exit 1; fi
echo "absorbed $(wc -l < <(printf '%s\n' "${FILES[@]}")) rebranded files; upstream pinned in desktop/UPSTREAM"
