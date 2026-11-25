hl.on("hyprland.start", function()
    -- systemd session: Fedora's xdg-desktop-portal and hyprpolkitagent only run inside
    -- graphical-session.target, which the plain "Hyprland" login entry never starts (uwsm does).
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP HYPRLAND_INSTANCE_SIGNATURE"
        .. " && systemctl --user start hyprland-session.target"
        .. " && systemctl --user start xdg-desktop-portal-hyprland xdg-desktop-portal hyprpolkitagent")

    -- Keyring
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

    -- Clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Auto delete trash 30 days old
    hl.exec_cmd("trash-empty 30")

    -- Cursors
    hl.exec_cmd("hyprctl setcursor " .. V.cursorTheme .. " " .. V.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme '" .. V.cursorTheme .. "'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. V.cursorSize)

    -- Location provider and night light
    hl.exec_cmd("/usr/libexec/geoclue-2.0/demos/agent")
    if V.nightLight then hl.exec_cmd("sleep 1 && gammastep") end

    -- Forward bluetooth media commands to MPRIS
    hl.exec_cmd("mpris-proxy")

    -- Resize and move windows based on matches (e.g. pip)
    hl.exec_cmd("shellscape resizer -d")

    -- Start shell
    hl.exec_cmd("shellscape shell -d")

    -- Idle daemon
    hl.exec_cmd("hypridle")
end)

-- Leave graphical-session.target so the next login starts its services fresh.
hl.on("hyprland.shutdown", function()
    hl.exec_cmd("systemctl --user stop hyprland-session.target")
end)
