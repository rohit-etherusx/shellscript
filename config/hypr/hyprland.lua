-- Shellscape Hyprland config (Lua port of the Caelestia hyprland.conf;
-- Hyprland 0.57 dropped the old hyprlang .conf format).
local hypr = os.getenv("HOME") .. "/.config/hypr"
local user = os.getenv("HOME") .. "/.config/shellscape"

local function exists(path)
    local f = io.open(path, "r")
    if f then f:close() end
    return f ~= nil
end

-- Colours: written by `shellscape scheme`/`wallpaper`; the default until the CLI has run once.
C = dofile(exists(hypr .. "/scheme/current.lua") and hypr .. "/scheme/current.lua" or hypr .. "/scheme/default.lua")
-- rgba(C.primary .. "e6") → "rgba(xxxxxxe6)"
function rgba(hexWithAlpha) return "rgba(" .. hexWithAlpha .. ")" end
function rgb(hex) return "rgb(" .. hex .. ")" end

dofile(hypr .. "/variables.lua")
if exists(user .. "/hypr-vars.lua") then dofile(user .. "/hypr-vars.lua") end

for _, part in ipairs({
    "monitors", "env", "general", "input", "misc", "animations",
    "decoration", "group", "execs", "rules", "keybinds",
}) do
    dofile(hypr .. "/hyprland/" .. part .. ".lua")
end

-- Any extra Hyprland config for this machine
if exists(user .. "/hypr-user.lua") then dofile(user .. "/hypr-user.lua") end
