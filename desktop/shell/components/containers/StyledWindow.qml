import Quickshell
import Quickshell.Wayland

PanelWindow {
    required property string name

    WlrLayershell.namespace: `shellscape-${name}`
    color: "transparent"
}
