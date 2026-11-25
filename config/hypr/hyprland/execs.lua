hl.on("hyprland.start", function()
    -- Keyring and auth
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")  -- polkit-gnome is not packaged for Fedora

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
    hl.exec_cmd("sleep 1 && gammastep")

    -- Forward bluetooth media commands to MPRIS
    hl.exec_cmd("mpris-proxy")

    -- Resize and move windows based on matches (e.g. pip)
    hl.exec_cmd("shellscape resizer -d")

    -- Start shell
    hl.exec_cmd("shellscape shell -d")

    -- Idle daemon
    hl.exec_cmd("hypridle")
end)
