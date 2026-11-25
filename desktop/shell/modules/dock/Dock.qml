pragma ComponentBehavior: Bound

import qs.components
import qs.components.containers
import qs.services
import qs.config
import qs.utils
import "../launcher/services"
import qs.components.effects
import qs.modules.controlcenter
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

// Shellscape's single bottom bar (replaces Caelestia's left bar): logo + workspaces,
// pinned apps and open windows in the centre, tray / network / bluetooth / battery /
// clock / power on the right. Right-click an app to pin/unpin it,
// middle-click to open a new window.
Item {
    id: root

    required property ShellScreen screen
    required property PersistentProperties visibilities

    function windowsOf(entry: DesktopEntry): list<var> {
        return Hyprland.toplevels.values.filter(t => root.matches(t, entry));
    }

    function matches(toplevel: var, entry: DesktopEntry): bool {
        const cls = (toplevel.lastIpcObject?.class ?? "").toLowerCase();
        if (!cls || !entry)
            return false;
        return cls === entry.id.toLowerCase() || cls === (entry.startupClass ?? "").toLowerCase() || DesktopEntries.heuristicLookup(cls) === entry;
    }

    function focus(toplevel: var): void {
        Hyprland.dispatch(`hl.dsp.focus({ window = "address:0x${toplevel.address}" })`);
    }

    // Open/close a drawer (dashboard, session, ...) on the monitor this bar is on
    function toggle(drawer: string): void {
        visibilities[drawer] = !visibilities[drawer];
    }

    function setPinned(entry: DesktopEntry, pin: bool): void {
        if (!entry)
            return;
        const ids = Config.dock.pinned.filter(id => id !== entry.id);
        Config.dock.pinned = pin ? [...ids, entry.id] : ids;
        Config.save();
    }

    // Looked up in applications.values (not byId) so the list re-evaluates once the
    // desktop entries finish loading after shell start.
    readonly property list<var> pinnedEntries: {
        const apps = DesktopEntries.applications.values;
        return Config.dock.pinned.map(id => apps.find(e => e.id === id)).filter(e => e);
    }
    // Windows that close before Hyprland reports their class (e.g. test runners opening and
    // closing windows in a loop) can linger in the toplevel list with no class; skip them.
    readonly property list<var> unpinnedWindows: Hyprland.toplevels.values.filter(t => t.lastIpcObject?.class && !pinnedEntries.some(e => matches(t, e)))

    // No background of its own: the frame (Border.qml) paints this strip, so the bar is part of it.
    Item {
        id: bar

        anchors.fill: parent

        // ── Left: logo (dashboard) + workspaces ──────────────────────────────
        RowLayout {
            anchors.left: parent.left
            anchors.leftMargin: Config.border.rounding
            anchors.verticalCenter: parent.verticalCenter
            spacing: Appearance.spacing.normal

            Clickable {
                onClicked: root.toggle("dashboard")

                ColouredIcon {
                    anchors.centerIn: parent
                    source: SysInfo.osLogo
                    implicitSize: Appearance.font.size.large * 1.2
                    colour: Colours.palette.m3tertiary
                }
            }

            Row {
                spacing: Appearance.spacing.small
                Layout.alignment: Qt.AlignVCenter

                Repeater {
                    model: Config.bar.workspaces.shown

                    StyledRect {
                        id: ws

                        required property int index
                        readonly property int wsId: Math.floor((Hyprland.activeWsId - 1) / 10) * 10 + index + 1
                        readonly property bool active: Hyprland.activeWsId === wsId
                        readonly property bool occupied: Hyprland.workspaces.values.some(w => w.id === wsId && w.toplevels.values.length > 0)

                        implicitWidth: active ? 28 : 12
                        implicitHeight: 12
                        radius: Appearance.rounding.full
                        color: active ? Colours.palette.m3primary : occupied ? Colours.palette.m3onSurfaceVariant : Colours.palette.m3outlineVariant

                        Behavior on implicitWidth { Anim {} }

                        StateLayer {
                            function onClicked(): void {
                                Hyprland.dispatch(`hl.dsp.focus({ workspace = ${ws.wsId} })`);
                            }
                        }
                    }
                }
            }
        }

        // ── Centre: pinned apps + other open windows ─────────────────────────
        RowLayout {
            anchors.centerIn: parent
            spacing: Appearance.spacing.small

            Repeater {
                model: root.pinnedEntries

                DockIcon {
                    required property DesktopEntry modelData

                    iconSource: Quickshell.iconPath(modelData?.icon ?? "", "image-missing")  // null while desktop files reload
                    windows: root.windowsOf(modelData)
                    onActivated: windows.length > 0 ? root.focus(windows[0]) : Apps.launch(modelData)
                    onLaunchNew: Apps.launch(modelData)
                    onTogglePin: root.setPinned(modelData, false)
                }
            }

            Separator { visible: root.unpinnedWindows.length > 0 }

            Repeater {
                model: root.unpinnedWindows

                DockIcon {
                    required property var modelData

                    iconSource: Icons.getAppIcon(modelData.lastIpcObject?.class ?? "", "image-missing")
                    windows: [modelData]
                    onActivated: root.focus(modelData)
                    onLaunchNew: root.focus(modelData)
                    onTogglePin: root.setPinned(DesktopEntries.heuristicLookup(modelData.lastIpcObject?.class ?? ""), true)
                }
            }
        }

        // ── Right: tray, status, clock, power ────────────────────────────────
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: Config.border.rounding
            anchors.verticalCenter: parent.verticalCenter
            spacing: Appearance.spacing.normal

            Repeater {
                model: SystemTray.items

                IconImage {
                    id: tray

                    required property SystemTrayItem modelData

                    implicitSize: Appearance.font.size.larger * 1.4
                    source: modelData.icon
                    Layout.alignment: Qt.AlignVCenter

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: event => {
                            if (event.button === Qt.LeftButton)
                                tray.modelData.activate();
                            else if (tray.modelData.hasMenu)
                                tray.modelData.display(QsWindow.window, tray.mapToItem(null, 0, 0).x, tray.mapToItem(null, 0, 0).y);
                        }
                    }
                }
            }

            Clickable {
                onClicked: WindowFactory.create(null, { active: "network" })

                MaterialIcon {
                    anchors.centerIn: parent
                    animate: true
                    text: Network.active ? Icons.getNetworkIcon(Network.active.strength ?? 0) : "wifi_off"
                    color: Colours.palette.m3secondary
                }
            }

            Clickable {
                onClicked: WindowFactory.create(null, { active: "bluetooth" })

                MaterialIcon {
                    anchors.centerIn: parent
                    animate: true
                    text: !Bluetooth.defaultAdapter?.enabled ? "bluetooth_disabled" : Bluetooth.devices.values.some(d => d.connected) ? "bluetooth_connected" : "bluetooth"
                    color: Colours.palette.m3secondary
                }
            }

            Row {
                visible: UPower.displayDevice.isLaptopBattery
                spacing: 2
                Layout.alignment: Qt.AlignVCenter

                MaterialIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    animate: true
                    fill: 1
                    text: {
                        const perc = UPower.displayDevice.percentage;
                        const charging = !UPower.onBattery;
                        if (perc === 1)
                            return charging ? "battery_charging_full" : "battery_full";
                        let level = Math.floor(perc * 7);
                        if (charging && (level === 4 || level === 1))
                            level--;
                        return charging ? `battery_charging_${(level + 3) * 10}` : `battery_${level}_bar`;
                    }
                    color: !UPower.onBattery || UPower.displayDevice.percentage > 0.2 ? Colours.palette.m3secondary : Colours.palette.m3error
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: `${Math.round(UPower.displayDevice.percentage * 100)}%`
                    font.pointSize: Appearance.font.size.small
                    color: Colours.palette.m3secondary
                }
            }

            Clickable {
                implicitWidth: clock.implicitWidth + Appearance.padding.normal * 2
                onClicked: root.toggle("dashboard")

                StyledText {
                    id: clock

                    anchors.centerIn: parent
                    text: Time.format(Config.services.useTwelveHourClock ? "hh:mm A" : "hh:mm")
                    font.family: Appearance.font.family.mono
                    font.pointSize: Appearance.font.size.normal
                    color: Colours.palette.m3tertiary
                }
            }

            Clickable {
                onClicked: root.toggle("session")

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "power_settings_new"
                    color: Colours.palette.m3error
                    font.bold: true
                }
            }
        }
    }

    // Round hover/click target for the icons in the bar
    component Clickable: Item {
        id: clickable

        signal clicked

        implicitWidth: Config.dock.height * 0.7
        implicitHeight: Config.dock.height * 0.7
        Layout.alignment: Qt.AlignVCenter

        StateLayer {
            radius: Appearance.rounding.full
            function onClicked(): void {
                clickable.clicked();
            }
        }
    }

    component Separator: StyledRect {
        implicitWidth: 2
        implicitHeight: Config.dock.height * 0.5
        radius: 1
        color: Colours.palette.m3outlineVariant
        Layout.alignment: Qt.AlignVCenter
    }

    component Anim: NumberAnimation {
        duration: Appearance.anim.durations.normal
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.anim.curves.standard
    }
}
