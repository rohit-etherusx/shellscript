import Quickshell.Io

// Bottom taskbar (Shellscape addition; Caelestia has no dock).
JsonObject {
    property bool enabled: true
    property int height: 52
    property int iconSize: 34
    // Desktop entry ids (the .desktop file name without ".desktop"). Missing apps are skipped.
    property list<string> pinned: ["kitty", "thunar", "com.microsoft.VSCode", "brave-browser", "google-chrome", "net.lutris.Lutris", "steam"]
}
