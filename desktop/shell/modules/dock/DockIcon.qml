import qs.components
import qs.services
import qs.config
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

// One dock entry: icon and a dot per open window (max 3).
Item {
    id: root

    property string iconSource
    property list<var> windows

    signal activated
    signal launchNew
    signal togglePin

    implicitWidth: Config.dock.iconSize + Appearance.padding.small * 2
    implicitHeight: Config.dock.height
    Layout.alignment: Qt.AlignVCenter

    StyledRect {
        anchors.fill: parent
        anchors.topMargin: Appearance.padding.smaller
        anchors.bottomMargin: Appearance.padding.smaller
        radius: Appearance.rounding.normal
        color: root.windows.some(w => w === Hyprland.activeToplevel) ? Colours.layer(Colours.palette.m3surfaceContainerHighest, 2) : "transparent"

        StateLayer {
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            function onClicked(event): void {
                if (event.button === Qt.RightButton)
                    root.togglePin();
                else if (event.button === Qt.MiddleButton)
                    root.launchNew();
                else
                    root.activated();
            }
        }
    }

    IconImage {
        id: icon

        anchors.centerIn: parent
        anchors.verticalCenterOffset: -2
        implicitSize: Config.dock.iconSize
        source: root.iconSource
        scale: hover.containsMouse ? 1.12 : 1

        Behavior on scale {
            NumberAnimation {
                duration: Appearance.anim.durations.small
            }
        }
    }

    MouseArea {
        id: hover

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        spacing: 3

        Repeater {
            model: Math.min(root.windows.length, 3)

            StyledRect {
                implicitWidth: 5
                implicitHeight: 5
                radius: 3
                color: Colours.palette.m3primary
            }
        }
    }
}
