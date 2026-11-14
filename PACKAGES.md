# Shellscape — dependency list

Everything is installed automatically by `./install.sh`. This file is the
human-readable inventory of what lands on your system and where it comes from.

## Fedora repositories (`dnf`)

| Module | Packages | Purpose |
|---|---|---|
| 00-preflight | `git` `curl` `unzip` `tar` | fetching / extracting everything else |
| 10-fonts | `jetbrains-mono-fonts` `fira-code-fonts` `adobe-source-code-pro-fonts` `google-noto-sans-fonts` `google-noto-sans-mono-fonts` `google-noto-emoji-fonts` `fontawesome-fonts-all` | base fonts (Fedora equivalents of the Arch repo's `fonts.sh`) |
| 20-cli-tools | `eza` `bat` `fzf` `zoxide` `ripgrep` `fd-find` | modern replacements for ls / cat / Ctrl-R / cd / grep / find |
| 30-zsh | `zsh` `zsh-autosuggestions` `zsh-syntax-highlighting` | the shell (plugins are also cloned from GitHub into Oh-My-Zsh) |
| 40-kitty | `kitty` | terminal emulator |
| 50-fastfetch | `fastfetch` `chafa` | system-info banner; chafa renders the logo in terminals without the kitty graphics protocol |
| 60-tmux | `tmux` | terminal multiplexer |
| 70-pokemon | `python3` | runtime for pokemon-colorscripts |

One-liner (what install.sh effectively runs, minus the already-installed ones):

```bash
sudo dnf install -y git curl unzip tar \
  jetbrains-mono-fonts fira-code-fonts adobe-source-code-pro-fonts \
  google-noto-sans-fonts google-noto-sans-mono-fonts google-noto-emoji-fonts fontawesome-fonts-all \
  eza bat fzf zoxide ripgrep fd-find \
  zsh zsh-autosuggestions zsh-syntax-highlighting \
  kitty fastfetch chafa tmux python3
```

## Fetched from the internet (no Fedora package) — or from `vendor/`

`./vendor.sh` snapshots all of these into `vendor/` (tarballs without `.git`);
`install.sh` uses the vendored copy when present and downloads otherwise.

| What | Source | Installed to |
|---|---|---|
| Oh-My-Zsh | https://install.ohmyz.sh (official installer, `--unattended --keep-zshrc`) | `~/.oh-my-zsh` |
| zsh-autosuggestions | https://github.com/zsh-users/zsh-autosuggestions | `~/.oh-my-zsh/custom/plugins/` |
| zsh-syntax-highlighting | https://github.com/zsh-users/zsh-syntax-highlighting | `~/.oh-my-zsh/custom/plugins/` |
| JetBrainsMono Nerd Font | https://github.com/ryanoasis/nerd-fonts/releases (latest `JetBrainsMono.zip`) | `~/.local/share/fonts/JetBrainsMonoNerdFont/` |
| TPM (tmux plugin manager) + tmux-sensible, tmux-yank, tmux-resurrect | https://github.com/tmux-plugins | `~/.tmux/plugins/` |
| pokemon-colorscripts | https://gitlab.com/phoneybadger/pokemon-colorscripts (built with its own `install.sh`) | `/opt/pokemon-colorscripts`, `/usr/local/bin/pokemon-colorscripts` |

## Bundled in this repo (from Arch-Hyprland)

- `config/zsh/themes/*.zsh-theme` — 7 Oh-My-Zsh themes (`agnosterzak` is the default)
- `config/fastfetch/*.jsonc` — 4 fastfetch layouts, `arch.png` swapped for `fedora.png`
  (`/usr/share/icons/hicolor/256x256/apps/fedora-logo-icon.png` from the `fedora-logos` package)

## Files Shellscape creates in `$HOME` (all symlinks into `Shellscape/config/`)

```
~/.zshrc            → config/zsh/.zshrc
~/.zprofile         → config/zsh/.zprofile
~/.config/zsh       → config/zsh
~/.config/kitty     → config/kitty
~/.config/fastfetch → config/fastfetch
~/.config/tmux      → config/tmux
```
Anything that already existed is moved to `<name>.bak.<timestamp>` and
restored by `./uninstall.sh`.
