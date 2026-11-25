-- Shellscape Hyprland variables (Lua port of the Caelestia variables.conf).
-- Override any of these per machine in ~/.config/shellscape/hypr-vars.lua, e.g.
--   V.browser = "brave-browser"
--   V.kbLayout = "de"
V = {
    -- Apps
    terminal     = "kitty",  -- Shellscape keeps kitty+zsh; foot+fish are installed too
    browser      = "firefox",
    editor       = "code",
    fileExplorer = "thunar",

    -- Keyboard
    kbLayout  = "us",
    kbVariant = "",

    -- Touchpad
    touchpadDisableTyping = true,
    touchpadScrollFactor  = 0.3,
    workSpaceSwipeFingers = 4,

    -- Blur
    blurEnabled      = true,
    blurSpecialWs    = false,
    blurPopups       = true,
    blurInputMethods = true,
    blurSize         = 8,
    blurPasses       = 2,
    blurXray         = false,

    -- Shadow
    shadowEnabled     = true,
    shadowRange       = 20,
    shadowRenderPower = 3,

    -- Gaps
    workspaceGaps       = 20,
    windowGapsIn        = 5,
    windowGapsOut       = 10,
    singleWindowGapsOut = 10,

    -- Window styling
    windowOpacity    = 0.95,
    windowRounding   = 10,
    windowBorderSize = 3,

    -- Misc
    volumeStep  = 10,  -- In percent
    cursorTheme = "breeze_cursors",  -- sweet-cursors is not packaged for Fedora
    cursorSize  = 24,
}
