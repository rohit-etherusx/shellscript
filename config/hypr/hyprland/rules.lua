local function rule(match, effects)
    effects.match = match
    hl.window_rule(effects)
end
local function float(match) rule(match, { float = true }) end
local function floatSized(match, size)
    rule(match, { float = true, size = size, center = true })
end

-- ######## Window rules ########
rule({ fullscreen = false }, { opacity = V.windowOpacity .. " override" })
rule({ class = "foot|kitty|equibop|org\\.quickshell|imv|swappy" }, { opaque = true })  -- Native transparency, or we want them opaque
rule({ float = true, xwayland = false }, { center = true })  -- Center all floating windows (not xwayland: popups)

-- Float
for _, c in ipairs({
    "guifetch", "yad", "zenity", "wev", "org\\.gnome\\.FileRoller", "file-roller",
    "blueman-manager", "com\\.github\\.GradienceTeam\\.Gradience", "feh", "imv",
    "system-config-printer", "org\\.quickshell",
}) do float({ class = c }) end

-- Float, resize and center
floatSized({ class = "foot", title = "nmtui" }, "60% 70%")
floatSized({ class = "org\\.gnome\\.Settings" }, "70% 80%")
floatSized({ class = "org\\.pulseaudio\\.pavucontrol|yad-icon-browser" }, "60% 70%")
floatSized({ class = "nwg-look" }, "50% 60%")

-- Special workspaces
rule({ class = "btop" }, { workspace = "special:sysmon" })
rule({ class = "feishin|Spotify|Supersonic" }, { workspace = "special:music" })
rule({ initial_title = "Spotify( Free)?" }, { workspace = "special:music" })  -- Spotify on Wayland has no class
rule({ class = "discord|equibop|vesktop|whatsapp" }, { workspace = "special:communication" })
rule({ class = "Todoist" }, { workspace = "special:todo" })

-- Dialogs
for _, t in ipairs({
    "(Select|Open)( a)? (File|Folder)(s)?", "File (Operation|Upload)( Progress)?", ".* Properties",
    "Export Image as PNG", "GIMP Crash Debug", "Save As", "Library",
}) do float({ title = t }) end

-- Picture in picture (resize and move done by `shellscape resizer`)
rule({ title = "Picture(-| )in(-| )[Pp]icture" }, {
    move = "100%-w-2% 100%-w-3%",  -- Initial move so the window doesn't shoot across from the center
    keep_aspect_ratio = true, float = true, pin = true,
})

-- Steam
rule({ title = "^$", class = "steam" }, { rounding = 10 })
float({ title = "Friends List", class = "steam" })
rule({ class = "steam_app_[0-9]+" }, { immediate = true, idle_inhibit = "always" })  -- Tearing + no idle in games

-- ATLauncher console
float({ class = "com-atlauncher-App", title = "ATLauncher Console" })
-- Autodesk Fusion 360
rule({ title = "Fusion360|(Marking Menu)", class = "fusion360\\.exe" }, { no_blur = true })
-- Xwayland popups
rule({ xwayland = true, title = "win[0-9]+" }, { no_dim = true, no_shadow = true, rounding = 10 })

-- ######## Workspace rules ########
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = V.singleWindowGapsOut })
hl.workspace_rule({ workspace = "f[1]s[false]",   gaps_out = V.singleWindowGapsOut })

-- ######## Layer rules ########
local function layer(ns, effects)
    effects.match = { namespace = ns }
    hl.layer_rule(effects)
end
layer("hyprpicker",   { animation = "fade" })  -- Colour picker out animation
layer("logout_dialog", { animation = "fade" })  -- wlogout
layer("selection",    { animation = "fade" })  -- slurp
layer("wayfreeze",    { animation = "fade" })
layer("launcher",     { animation = "popin 80%", blur = true })  -- Fuzzel
-- Shell
layer("shellscape-(border-exclusion|area-picker)", { no_anim = true })
layer("shellscape-(drawers|background)", { animation = "fade" })
layer("shellscape-drawers", { blur = true, ignore_alpha = 0.57 })
