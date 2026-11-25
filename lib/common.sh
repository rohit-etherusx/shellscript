#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# Shellscape — shared helpers. Sourced by install.sh, uninstall.sh and every
# module in modules/: logging, dnf, backup+symlink, git clone, download, vendor.
# ──────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Paths ─────────────────────────────────────────────────────────────────────
SHELLSCAPE_DIR="${SHELLSCAPE_DIR:-$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)}"
export SHELLSCAPE_DIR
CONFIG_DIR="$SHELLSCAPE_DIR/config"
DESKTOP_DIR="$SHELLSCAPE_DIR/desktop"   # Quickshell shell + Python CLI (imported by tools/absorb.sh)
LOG_DIR="$SHELLSCAPE_DIR/logs"
BUILD_DIR="$SHELLSCAPE_DIR/build"
VENDOR_DIR="$SHELLSCAPE_DIR/vendor"   # offline copies of everything not in dnf (see vendor.sh)
mkdir -p "$LOG_DIR" "$BUILD_DIR"
LOG="${LOG:-$LOG_DIR/install-$(date +%Y%m%d-%H%M%S).log}"
export LOG
LINKS_LIST="$LOG_DIR/links.list"       # every symlink we created  (used by uninstall.sh)
BACKUPS_LIST="$LOG_DIR/backups.list"   # every backup we made      (used by uninstall.sh)

# ── Colors / tags ─────────────────────────────────────────────────────────────
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  RESET="$(tput sgr0)"; BOLD="$(tput bold)"
  RED="$(tput setaf 1)"; GREEN="$(tput setaf 2)"; YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"; MAGENTA="$(tput setaf 5)"; CYAN="$(tput setaf 6)"
else
  RESET=""; BOLD=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""
fi
OK="${GREEN}[OK]${RESET}"
ERROR="${RED}[ERROR]${RESET}"
NOTE="${YELLOW}[NOTE]${RESET}"
INFO="${BLUE}[INFO]${RESET}"
WARN="${RED}[WARN]${RESET}"
ACTION="${CYAN}[ACTION]${RESET}"

log()     { printf '%s\n' "$*" | tee -a "$LOG"; }
ok()      { log "${OK} $*"; }
info()    { log "${INFO} $*"; }
note()    { log "${NOTE} $*"; }
warn()    { log "${WARN} $*"; }
error()   { log "${ERROR} $*" >&2; }
die()     { error "$*"; exit 1; }
section() { printf '\n%s━━ %s ━━%s\n' "${BOLD}${MAGENTA}" "$*" "${RESET}" | tee -a "$LOG"; }

# ── Flags (exported by install.sh) ────────────────────────────────────────────
ASSUME_YES="${ASSUME_YES:-0}"

need_cmd() { command -v "$1" >/dev/null 2>&1; }

# ask_yes_no "Question?" [default y|n]  → returns 0 for yes. --yes answers yes to everything.
ask_yes_no() {
  local q="$1" def="${2:-y}" ans
  [[ "$ASSUME_YES" == 1 ]] && return 0
  if [[ "$def" == y ]]; then q+=" [Y/n] "; else q+=" [y/N] "; fi
  read -r -p "${ACTION} ${q}" ans </dev/tty || ans=""
  ans="${ans:-$def}"
  [[ "${ans,,}" == y* ]]
}

# run_logged "label" cmd args...  → runs cmd with all output appended to $LOG,
# shows a spinner while it runs. Returns the command's exit code.
run_logged() {
  local label=$1; shift
  if [[ ! -t 1 ]]; then
    printf '%s %s\n' "$NOTE" "$label"
    "$@" >>"$LOG" 2>&1
    return
  fi
  "$@" >>"$LOG" 2>&1 &
  local pid=$! i=0 rc=0
  local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  tput civis 2>/dev/null || true
  while kill -0 "$pid" 2>/dev/null; do
    printf '\r%s %s %s' "$NOTE" "$label" "${frames:$((i++ % 10)):1}"
    sleep 0.15
  done
  wait "$pid" || rc=$?
  tput cnorm 2>/dev/null || true
  printf '\r\033[K'
  return "$rc"
}

# ── Packages (dnf) ────────────────────────────────────────────────────────────
pkg_installed() { rpm -q "$1" >/dev/null 2>&1; }

# install_pkgs pkg...  → skips already-installed packages, installs the rest in
# ONE dnf transaction, then verifies each. Returns 1 if any package is missing.
install_pkgs() {
  local missing=() failed=() p
  for p in "$@"; do
    if pkg_installed "$p"; then
      info "${MAGENTA}$p${RESET} is already installed. Skipping..."
    else
      missing+=("$p")
    fi
  done
  [[ ${#missing[@]} -eq 0 ]] && return 0

  run_logged "Installing ${YELLOW}${missing[*]}${RESET}" \
    sudo -n dnf install -y --skip-unavailable "${missing[@]}" \
    || warn "dnf exited with an error — see $LOG"

  for p in "${missing[@]}"; do
    if pkg_installed "$p"; then ok "Installed ${YELLOW}$p${RESET}"; else failed+=("$p"); fi
  done
  if [[ ${#failed[@]} -gt 0 ]]; then
    error "Failed to install: ${failed[*]} (see $LOG)"
    return 1
  fi
}

# enable_copr owner/project  → `dnf copr enable` once (needs dnf5-plugins / dnf-plugins-core)
enable_copr() {
  if dnf copr list 2>/dev/null | grep "/$1\b" >/dev/null && ! dnf copr list 2>/dev/null | grep "/$1 (disabled)" >/dev/null; then
    info "COPR $1 already enabled"; return 0
  fi
  run_logged "Enabling COPR ${YELLOW}$1${RESET}" sudo -n dnf copr enable -y "$1" \
    && ok "Enabled COPR $1"
}

# ── Dotfiles ──────────────────────────────────────────────────────────────────
# link_dotfile <source inside config/> <target in $HOME>
#   • already correct symlink → skip
#   • existing file/dir/other symlink → moved to <target>.bak.<timestamp>
#   • creates the symlink and records it for uninstall.sh
link_dotfile() {
  local src=$1 dst=$2
  [[ -e "$src" ]] || die "link_dotfile: source '$src' does not exist"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    info "Already linked: $dst"
    return 0
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    local bak="$dst.bak.$(date +%Y%m%d-%H%M%S)"
    mv "$dst" "$bak"
    note "Backed up $dst → $bak"
    printf '%s\t%s\n' "$dst" "$bak" >>"$BACKUPS_LIST"
  fi
  ln -sfn "$src" "$dst"
  ok "Linked $dst → $src"
  grep -qxF "$dst" "$LINKS_LIST" 2>/dev/null || echo "$dst" >>"$LINKS_LIST"
}

# vendor_extract <name> <dest-dir>  → unpacks vendor/<name>.tar.xz (or .tar.gz;
# single top-level dir) into <dest-dir>. Returns 1 (quietly) when there is no
# vendored copy. tar picks the decompressor from the file itself.
vendor_extract() {
  local name=$1 dest=$2 tb
  for tb in "$VENDOR_DIR/$name.tar.xz" "$VENDOR_DIR/$name.tar.gz"; do [[ -s "$tb" ]] && break; done
  [[ -s "$tb" ]] || return 1
  mkdir -p "$dest"
  run_logged "Unpacking vendored ${YELLOW}$name${RESET}" tar -xf "$tb" -C "$dest" --strip-components=1 \
    && ok "Installed $name from vendor/"
}

# git_clone <url> <dir> [extra git-clone args]  → skip if present; use
# vendor/<repo-name>.tar.xz when it exists; otherwise shallow clone.
git_clone() {
  local url=$1 dir=$2; shift 2
  if [[ -d "$dir/.git" || -n "$(ls -A "$dir" 2>/dev/null)" ]]; then
    info "Already present: $dir"
    return 0
  fi
  local name; name="$(basename "$url" .git)"
  vendor_extract "$name" "$dir" && return 0
  run_logged "Cloning ${YELLOW}$url${RESET}" git clone --depth=1 "$@" "$url" "$dir" \
    && ok "Cloned $name"
}

# download <url> <dest-file>  → skip if dest exists; copy vendor/<file> when it
# exists; otherwise curl with retries.
download() {
  local url=$1 dest=$2 name; name="$(basename "$dest")"
  if [[ -s "$dest" ]]; then info "Already downloaded: $name"; return 0; fi
  mkdir -p "$(dirname "$dest")"
  if [[ -s "$VENDOR_DIR/$name" ]]; then
    cp "$VENDOR_DIR/$name" "$dest"; ok "Using vendored $name"; return 0
  fi
  run_logged "Downloading ${YELLOW}$name${RESET}" \
    curl -fL --retry 3 --retry-delay 2 -o "$dest" "$url" \
    && ok "Downloaded $name"
}
