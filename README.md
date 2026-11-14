# Shellscape

One-command terminal ricing for **Fedora KDE** (built and tested on Fedora 43,
Plasma 6.7). It ports the terminal half of
[JaKooLit's Arch-Hyprland](https://github.com/JaKooLit/Arch-Hyprland) from
`pacman`/AUR to `dnf`, themes everything in **Catppuccin Mocha**, and keeps every
config file inside this folder so you can version, edit and move it as one unit.

```bash
git clone <this repo> ~/projects/linux-ricing/Shellscape
cd ~/projects/linux-ricing/Shellscape
./install.sh
```

Log out and back in (or `exec zsh`), press **Ctrl+Alt+T**, done.

---

## What you get

| Area | Details |
|---|---|
| **Shell** | zsh + Oh-My-Zsh, `shellscape` prompt (rounded powerline pills: time · directory · git · user), autosuggestions, syntax highlighting, fzf history, zoxide |
| **Terminal** | kitty: JetBrainsMono Nerd Font, Catppuccin Mocha, 95 % opacity with blur, cursor trail, powerline tabs. Registered as KDE's default terminal and bound to `Ctrl+Alt+T` |
| **Ptyxis** | Fedora's stock terminal gets the same Nerd Font, palette, beam cursor and opacity, so it matches if you open it anyway |
| **CLI tools** | eza (`ls`), bat (`cat`, man pages), fzf, zoxide, ripgrep, fd — all themed to match |
| **Banner** | fastfetch with the Fedora logo, or a random Pokémon sprite next to the system info, revealed line by line on every new shell |
| **tmux** | `Ctrl-a` prefix, mouse, vi keys, Catppuccin status bar, TPM with sensible / yank / resurrect |
| **Desktop** | KDE effects: glide open/close, wobbly windows, magic-lamp minimize, blur, translucency while moving, dimmed dialog parents |
| **Fonts** | JetBrainsMono Nerd Font plus Fedora's JetBrains Mono, Fira Code, Source Code Pro, Noto, Noto Emoji, Font Awesome |

Everything is a symlink from `~` back into `config/`, so editing a file here
changes the live config immediately.

---

## Requirements

- Fedora (the preflight module refuses anything else) with `sudo` access.
- Internet for the first run (dnf packages, Nerd Font, Oh-My-Zsh, plugins), or a
  populated `vendor/` folder for everything except dnf. See [Offline installs](#offline-installs).
- KDE Plasma for the kitty default-terminal, Ptyxis and desktop-effects modules.
  They skip themselves cleanly on other desktops.

---

## Usage

```bash
./install.sh                     # interactive: confirms the module list, asks for sudo once
./install.sh --yes               # unattended
./install.sh --list              # show modules and what they do
./install.sh --only zsh          # run one module ("zsh", "30-zsh" or "30" all work)
./install.sh --skip pokemon --skip kde-effects
./uninstall.sh                   # remove symlinks, restore backups, offer to reset the shell
./uninstall.sh --purge           # also remove Oh-My-Zsh, TPM, the Nerd Font, pokemon-colorscripts and the dnf packages
./vendor.sh                      # snapshot every non-dnf download into vendor/ for offline installs
```

Re-running `./install.sh` is always safe. Every module checks what is already
installed, linked or configured and only does what is missing. A log of each run
lands in `logs/`.

### Modules

Modules live in `modules/NN-name.sh` and run in numeric order.

| Module | What it does |
|---|---|
| `00-preflight` | Verifies Fedora, non-root, sudo and internet. Installs git, curl, unzip, tar. Creates `~/.config`, `~/.local/bin`, `~/.local/share/fonts`. |
| `10-fonts` | Fedora font packages plus JetBrainsMono Nerd Font into `~/.local/share/fonts/JetBrainsMonoNerdFont/`. |
| `20-cli-tools` | eza, bat, fzf, zoxide, ripgrep, fd. Links the eza and bat Catppuccin themes. |
| `30-zsh` | zsh, Oh-My-Zsh (unattended, keeps our `.zshrc`), autosuggestions and syntax-highlighting plugins, bundled prompt themes. Offers to make zsh the login shell. |
| `40-kitty` | kitty plus config. Makes kitty KDE's default terminal, moves `Ctrl+Alt+T` from Konsole to kitty, writes `~/.config/xdg-terminals.list`. |
| `45-ptyxis` | Points Ptyxis at the Nerd Font, the built-in "Catppuccin Mocha" palette and a blinking beam cursor. Skips if Ptyxis is absent. |
| `50-fastfetch` | fastfetch and chafa, links the four fastfetch layouts and the Fedora logo. |
| `60-tmux` | tmux and config, clones TPM and installs its plugins. |
| `70-pokemon` | Builds pokemon-colorscripts from GitLab into `/opt` and switches the startup banner to the Pokémon layout. |
| `80-kde-effects` | Enables the KWin effects listed above, bumps blur strength, sets Ptyxis to 92 % opacity, and reloads KWin live over D-Bus. Asks first. |

---

## Layout

```
Shellscape/
├── install.sh          entry point: runs modules/ in order, prints a summary
├── uninstall.sh        removes symlinks, restores backups (--purge removes packages too)
├── vendor.sh           snapshots non-dnf downloads into vendor/ for offline installs
├── PACKAGES.md         every dependency and where it comes from
├── lib/common.sh       shared helpers: logging, dnf, backup+symlink, git clone, download, vendor
├── modules/            one self-contained, idempotent step each (NN-name.sh)
├── config/             the source of truth, symlinked into ~
│   ├── zsh/            .zshrc  .zprofile  aliases.zsh  colors.zsh  themes/*.zsh-theme
│   ├── kitty/          kitty.conf  theme.conf (Catppuccin Mocha)
│   ├── fastfetch/      config.jsonc  config-v2  config-compact  config-pokemon  fedora.png
│   ├── tmux/           tmux.conf  plugins/ (populated by TPM at install time)
│   ├── eza/            theme.yml
│   └── bat/            config
├── vendor/             offline copies: Nerd Font zip, Oh-My-Zsh, zsh plugins, TPM, pokemon-colorscripts
├── logs/               install logs, links.list, backups.list      (gitignored)
└── build/              downloaded zips and cloned sources           (gitignored)
```

### Files Shellscape creates in `$HOME`

All of these are symlinks into `config/`. Anything that already existed is moved
to `<name>.bak.<timestamp>` and put back by `./uninstall.sh`.

```
~/.zshrc             → config/zsh/.zshrc
~/.zprofile          → config/zsh/.zprofile
~/.config/zsh        → config/zsh
~/.config/kitty      → config/kitty
~/.config/fastfetch  → config/fastfetch
~/.config/tmux       → config/tmux
~/.config/eza        → config/eza
~/.config/bat        → config/bat
```

Settings that are not files (Ptyxis font and palette, KDE default terminal, the
`Ctrl+Alt+T` shortcut, KWin effects) are written with `gsettings`,
`kwriteconfig6` and D-Bus, and are listed in each module's header comment.

---

## Customising

### Prompt

`config/zsh/.zshrc` sets `ZSH_THEME="shellscape"`. The theme lives in
`config/zsh/themes/shellscape.zsh-theme`: two lines, rounded segments, Catppuccin
colours defined in one map at the top of the file. It shows a red ✘ when the last
command failed, ⚡ as root, ⚙ with background jobs, and a git segment that goes
green (clean), yellow (untracked) or red (modified/deleted) with ahead/behind counts.

Other bundled themes from Arch-Hyprland: `agnosterzak antares bullet-train
color-input comfyline emoji fishbone++`, plus everything Oh-My-Zsh ships.

### Startup banner

Three variables at the top of the banner section in `config/zsh/.zshrc`:

```zsh
SHELLSCAPE_BANNER="pokemon"     # fastfetch | pokemon | none
SHELLSCAPE_BANNER_ANIM=1        # 1 = reveal line by line, 0 = instant
SHELLSCAPE_BANNER_DELAY=3       # hundredths of a second between lines
```

fastfetch layouts are in `config/fastfetch/`. `config-pokemon.jsonc` is the one
used next to the sprite; `config-compact.jsonc` is used for the plain banner.

### Colours

Everything is Catppuccin Mocha. The places to change if you want another palette:

| What | File |
|---|---|
| Prompt | `config/zsh/themes/shellscape.zsh-theme` (the `SS` map) |
| Command-line syntax and autosuggestions | `config/zsh/colors.zsh` |
| kitty | `config/kitty/theme.conf` |
| eza listings | `config/eza/theme.yml` |
| bat | `config/bat/config` (`--theme`) |
| fzf | `FZF_DEFAULT_OPTS` in `config/zsh/.zshrc` |
| tmux status bar | `config/tmux/tmux.conf` |
| Ptyxis | palette name in `modules/45-ptyxis.sh` |

### Aliases

From `config/zsh/aliases.zsh`:

| Alias | Runs |
|---|---|
| `ls` `l` `la` `lla` `lt` | eza with icons, directories first; `l`/`lla` add git status, `lt` is a two-level tree |
| `cat` / `catn` | bat without paging / plain GNU cat |
| `update` `install` `remove` `search` | the matching `dnf` commands |
| `..` `...` `cls` `ff` | up one/two dirs, clear, fastfetch |
| `shellscape` | re-run the installer from anywhere |
| `zshrc` | open `config/zsh/.zshrc` in `$EDITOR` |

Machine-specific additions go in `~/.zshrc.local`, which is sourced last and not
tracked.

### Keybindings

**kitty** (on top of the defaults)

| Keys | Action |
|---|---|
| `Ctrl+Shift+Enter` / `Ctrl+Shift+T` | new window / new tab in the current directory |
| `Ctrl+Shift+←` / `→` | previous / next tab |
| `Ctrl+Shift+=` / `-` / `0` | font size up / down / reset |
| `F11` | fullscreen |
| `Ctrl+Shift+Z` / `X` | jump to previous / next prompt (shell integration) |

**tmux** (prefix is `Ctrl-a`)

| Keys | Action |
|---|---|
| `prefix` `\|` / `-` | split right / below, in the current directory |
| `prefix` `c` | new window in the current directory |
| `prefix` `h` `j` `k` `l` | move between panes; `H J K L` resize |
| `prefix` `r` | reload the config |
| `prefix` `I` | install / update TPM plugins |
| `v` / `y` in copy mode | begin selection / yank |

**zsh**: `Ctrl-R` fuzzy history, `Ctrl-T` fuzzy file picker, `Alt-C` fuzzy cd,
`z <dir>` zoxide jump, `Esc Esc` prefixes the line with `sudo`.

---

## Offline installs

`./vendor.sh`, run on a machine where the installer has already completed, packs
every non-dnf dependency into `vendor/` (around 140 MB): the Nerd Font zip,
Oh-My-Zsh, both zsh plugins, TPM and pokemon-colorscripts. `install.sh` prefers
those copies automatically and only downloads what is missing, so on a new
machine the only network access needed is Fedora's own package repos.

Copy the whole folder anywhere (git, rsync, USB) and run `./install.sh`. The
symlinks are absolute, so the folder can live at any path. If you move it
*after* installing, re-run `./install.sh` to re-link.

---

## Troubleshooting

**Stray letters or boxes around the prompt segments.** The terminal is not using
a Nerd Font. kitty is configured for it already; for Ptyxis run
`./install.sh --only ptyxis`; for anything else pick "JetBrainsMono Nerd Font" in
its font settings.

**A command in `~/.local/bin` is "not found" in a new terminal.** Ptyxis, Konsole
and kitty open non-login shells, so `.zprofile` is skipped. `.zshrc` prepends
`~/.local/bin` and `~/bin` itself, so this only happens if that block was
removed.

**Listings or syntax colours look wrong in Ptyxis.** Its palette setting must be
exactly `Catppuccin Mocha`. Check with
`gsettings get org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/<uuid>/ palette`.

**KDE effects did not change.** KWin's reconfigure call does not load or unload
effects. The module toggles each one over D-Bus; verify with:

```bash
gdbus call --session --dest org.kde.KWin --object-path /Effects \
  --method org.freedesktop.DBus.Properties.Get org.kde.kwin.Effects loadedEffects
```

Blur only applies to windows that ask for it. kitty does on Plasma 6.4+; Ptyxis
(GTK) does not, so its translucency shows the wallpaper unblurred.

**The first prompt after login shows ✘.** `.zshrc` ends with `true` to prevent
exactly this. If you add lines after it, keep `true` last.

**tmux plugins missing.** Press `prefix` `I` inside tmux, or run
`~/.tmux/plugins/tpm/bin/install_plugins`.

**Something failed mid-install.** Check the newest file in `logs/` and re-run
`./install.sh`. Only the missing parts are redone.

---

## Adding a module

Create `modules/NN-name.sh`, make it executable, and `install.sh` picks it up:

```bash
#!/usr/bin/env bash
# desc: One-line description shown by --list
source "$(dirname "$(readlink -f "$0")")/../lib/common.sh"

install_pkgs some-package another-package
link_dotfile "$CONFIG_DIR/whatever" "$HOME/.config/whatever"
```

Helpers from `lib/common.sh`: `install_pkgs`, `link_dotfile`, `git_clone`,
`download`, `vendor_extract`, `run_logged`, `ask_yes_no`, `need_cmd`, and the
loggers `ok` `info` `note` `warn` `error` `die` `section`. `ASSUME_YES=1` is
exported when the installer runs with `--yes`, and `ask_yes_no` honours it.
Keep modules idempotent: check before you change, and exit 0 when there is
nothing to do.

---

## Credits

- Install flow, prompt themes and fastfetch layouts:
  [JaKooLit/Arch-Hyprland](https://github.com/JaKooLit/Arch-Hyprland)
- Colours: [Catppuccin Mocha](https://github.com/catppuccin)
- Sprites: [pokemon-colorscripts](https://gitlab.com/phoneybadger/pokemon-colorscripts)
- Font: [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) build of JetBrains Mono
