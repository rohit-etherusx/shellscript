-- Everything lives in the "global" submap, like Caelestia's keybinds.conf:
-- Hyprland only allows the catch-all bind (launcherInterrupt) inside a submap.
hl.define_submap("global", function()
local d = hl.dsp
local launcherInterrupt = hl.dsp.global("shellscape:launcherInterrupt")

-- Tapping Super alone opens the launcher; any Super shortcut must cancel that first.
-- (The catch-all below only fires for keys that have no bind of their own.)
local function bind(keys, dsp, opts)
    if keys:find("Super") and not (opts and opts.mouse) and keys ~= "Super + Super_L" then
        local action = dsp
        dsp = function()
            hl.dispatch(launcherInterrupt)
            if type(action) == "function" then action() else hl.dispatch(action) end
        end
    end
    hl.bind(keys, dsp, opts)
end
local function exec(cmd) return d.exec_cmd(cmd) end
local function app(cmd) return d.exec_cmd("app2unit -- " .. cmd) end
local function global(name) return d.global("shellscape:" .. name) end
local locked = { locked = true }
local rep = { repeating = true }

-- ## Shell keybinds
-- Launcher: tap Super. Any other key/click while Super is held cancels it.
bind("Super + Super_L", global("launcher"), { ignore_mods = true })
-- Hyprland 0.57 can't parse "Super + catchall" (it becomes a literal key), so the catch-all has
-- no modifier. Same effect: the shell only checks the interrupt between Super press and release.
bind("catchall", global("launcherInterrupt"), { ignore_mods = true, non_consuming = true })
for _, k in ipairs({ "mouse:272", "mouse:273", "mouse:274", "mouse:275",
                     "mouse:276", "mouse:277", "mouse_up", "mouse_down" }) do
    bind("Super + " .. k, global("launcherInterrupt"), { ignore_mods = true, non_consuming = true })
end

-- Misc
bind("Ctrl + Alt + Delete", global("session"))
bind("Ctrl + Alt + C", global("clearNotifs"), locked)
bind("Super + K", global("showall"))
bind("Super + I", global("controlCenter"))  -- Shellscape settings: network, bluetooth, audio
bind("Super + L", global("lock"))

-- Restore lock (restart the shell, then lock)
bind("Super + Alt + L", exec("shellscape shell -d; sleep 1; qs -c shellscape ipc call lock lock"), locked)

-- Brightness
bind("XF86MonBrightnessUp", global("brightnessUp"), locked)
bind("XF86MonBrightnessDown", global("brightnessDown"), locked)

-- Media
bind("Ctrl + Super + Space", global("mediaToggle"), locked)
bind("XF86AudioPlay", global("mediaToggle"), locked)
bind("XF86AudioPause", global("mediaToggle"), locked)
bind("Ctrl + Super + Equal", global("mediaNext"), locked)
bind("XF86AudioNext", global("mediaNext"), locked)
bind("Ctrl + Super + Minus", global("mediaPrev"), locked)
bind("XF86AudioPrev", global("mediaPrev"), locked)
bind("XF86AudioStop", global("mediaStop"), locked)

-- Kill/restart the shell
bind("Ctrl + Super + Shift + R", exec("qs -c shellscape kill"), { release = true })
bind("Ctrl + Super + Alt + R", exec("qs -c shellscape kill; shellscape shell -d"), { release = true })

-- ## Workspaces (grouped in tens: Super+N = workspace N of the current group,
-- Ctrl+Super+N = same slot in group N). Replaces Caelestia's wsaction.fish.
local function activeWs()
    local ws = hl.get_active_workspace()
    return ws and ws.id or 1
end
local function inGroup(n) return math.floor((activeWs() - 1) / 10) * 10 + n end
local function ofGroup(n) return (n - 1) * 10 + activeWs() % 10 end

for i = 1, 10 do
    local key = tostring(i % 10)
    bind("Super + " .. key,              function() hl.dispatch(d.focus({ workspace = inGroup(i) })) end)
    bind("Ctrl + Super + " .. key,       function() hl.dispatch(d.focus({ workspace = ofGroup(i) })) end)
    bind("Super + Alt + " .. key,        function() hl.dispatch(d.window.move({ workspace = inGroup(i) })) end)
    bind("Ctrl + Super + Alt + " .. key, function() hl.dispatch(d.window.move({ workspace = ofGroup(i) })) end)
end

-- Go to workspace -1/+1
bind("Super + mouse_down", d.focus({ workspace = "-1" }))
bind("Super + mouse_up", d.focus({ workspace = "+1" }))
bind("Ctrl + Super + left", d.focus({ workspace = "-1" }), rep)
bind("Ctrl + Super + right", d.focus({ workspace = "+1" }), rep)
bind("Super + Page_Up", d.focus({ workspace = "-1" }), rep)
bind("Super + Page_Down", d.focus({ workspace = "+1" }), rep)
-- Go to workspace group -1/+1
bind("Ctrl + Super + mouse_down", d.focus({ workspace = "-10" }))
bind("Ctrl + Super + mouse_up", d.focus({ workspace = "+10" }))
-- Toggle special workspace
bind("Super + S", exec("shellscape toggle specialws"))

-- Move window to workspace -1/+1
bind("Super + Alt + Page_Up", d.window.move({ workspace = "-1" }), rep)
bind("Super + Alt + Page_Down", d.window.move({ workspace = "+1" }), rep)
bind("Super + Alt + mouse_down", d.window.move({ workspace = "-1" }))
bind("Super + Alt + mouse_up", d.window.move({ workspace = "+1" }))
bind("Ctrl + Super + Shift + right", d.window.move({ workspace = "+1" }), rep)
bind("Ctrl + Super + Shift + left", d.window.move({ workspace = "-1" }), rep)
-- Move window to/from special workspace
bind("Ctrl + Super + Shift + up", d.window.move({ workspace = "special:special" }))
bind("Ctrl + Super + Shift + down", d.window.move({ workspace = "e+0" }))
bind("Super + Alt + S", d.window.move({ workspace = "special:special" }))

-- Window groups
bind("Alt + Tab", d.window.cycle_next(), rep)
bind("Shift + Alt + Tab", d.window.cycle_next({ prev = true }), rep)
bind("Ctrl + Alt + Tab", d.group.next(), rep)
bind("Ctrl + Shift + Alt + Tab", d.group.prev(), rep)
bind("Super + Comma", d.group.toggle())
bind("Super + U", d.window.move({ out_of_group = true }))
bind("Super + Shift + Comma", d.group.lock_active({ action = "toggle" }))

-- Window actions
for key, dir in pairs({ left = "left", right = "right", up = "up", down = "down" }) do
    bind("Super + " .. key, d.focus({ direction = dir }))
    bind("Super + Shift + " .. key, d.window.move({ direction = dir }))
end
bind("Super + Minus", d.layout("splitratio -0.1"), rep)
bind("Super + Equal", d.layout("splitratio 0.1"), rep)
bind("Super + mouse:272", d.window.drag(), { mouse = true })
bind("Super + Z", d.window.drag(), { mouse = true })
bind("Super + mouse:273", d.window.resize(), { mouse = true })
bind("Super + X", d.window.resize(), { mouse = true })
bind("Ctrl + Super + Backslash", d.window.center())
bind("Ctrl + Super + Alt + Backslash", function()
    local m = hl.get_active_monitor()  -- resize takes pixels, not percentages
    hl.dispatch(d.window.resize({ x = math.floor(m.width / m.scale * 0.55), y = math.floor(m.height / m.scale * 0.7) }))
    hl.dispatch(d.window.center())
end)
bind("Super + Alt + Backslash", exec("shellscape resizer pip"))  -- Picture-in-picture
bind("Super + P", d.window.pin())
bind("Super + F", d.window.fullscreen({ mode = "fullscreen" }))
bind("Super + Alt + F", d.window.fullscreen({ mode = "maximized" }))  -- Fullscreen with borders
bind("Super + Alt + Space", d.window.float({ action = "toggle" }))
bind("Super + Q", d.window.close())

-- Special workspace toggles
bind("Ctrl + Shift + Escape", exec("shellscape toggle sysmon"))
bind("Super + M", exec("shellscape toggle music"))
bind("Super + D", exec("shellscape toggle communication"))
bind("Super + R", exec("shellscape toggle todo"))

-- Apps
bind("Super + T", app(V.terminal))
bind("Super + B", app(V.browser))
bind("Super + C", app(V.editor))
bind("Super + E", app(V.fileExplorer))
bind("Ctrl + Alt + Escape", app("qps"))
bind("Ctrl + Alt + V", app("pavucontrol"))

-- Utilities
bind("Print", exec("shellscape screenshot"), locked)  -- Full screen capture > clipboard
bind("Super + Shift + S", global("screenshotFreeze"))  -- Capture region (freeze)
bind("Super + Shift + Alt + S", global("screenshot"))  -- Capture region
bind("Super + Alt + R", exec("shellscape record -s"))  -- Record screen with sound
bind("Ctrl + Alt + R", exec("shellscape record"))  -- Record screen
bind("Super + Shift + Alt + R", exec("shellscape record -r"))  -- Record region
bind("Super + Shift + C", exec("hyprpicker -a"))  -- Colour picker

-- Volume
local step = V.volumeStep .. "%"
bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), locked)
bind("Super + Shift + M", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), locked)
bind("XF86AudioRaiseVolume", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ " .. step .. "+"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. step .. "-"), { locked = true, repeating = true })

-- Sleep
bind("Super + Shift + L", exec("systemctl suspend-then-hibernate"))

-- Clipboard and emoji picker
bind("Super + V", exec("pkill fuzzel || shellscape clipboard"))
bind("Super + Alt + V", exec("pkill fuzzel || shellscape clipboard -d"))
bind("Super + Period", exec("pkill fuzzel || shellscape emoji -p"))
bind("Ctrl + Shift + Alt + V", exec([[sleep 0.5s && ydotool type -d 1 "$(cliphist list | head -1 | cliphist decode)"]]), locked)  -- Alternate paste

-- Testing
bind("Super + Alt + F12", exec([[notify-send -u low -i dialog-information-symbolic 'Test notification' "Here's a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!" -a 'Shell' -A "Test1=I got it!" -A "Test2=Another action"]]), locked)
end)

-- Enter the submap at login and after every config reload (Hyprland resets it on reload).
local function enterGlobal() hl.dispatch(hl.dsp.submap("global")) end
hl.on("hyprland.start", enterGlobal)
hl.on("config.reloaded", enterGlobal)
