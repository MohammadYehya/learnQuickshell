// shell.qml
import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    // Shared state — the bar reads/writes this, the drawer reads it
    property bool drawerOpen: false

    // ── The taskbar at the bottom ─────────────────────────────
    PanelWindow {
        id: taskbar

        anchors {
            left: true
            right: true
            bottom: true
        }
        implicitHeight: 40
        color: "#1a1b26"

        // Reserve space so maximized apps don't overlap the bar
        exclusionMode: ExclusionMode.Auto

        Text {
            anchors.centerIn: parent
            text: root.drawerOpen ? "Click to close ▼" : "Click to open ▲"
            color: "#a9b1d6"
            font.pixelSize: 14
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.drawerOpen = !root.drawerOpen
        }
    }

    // ── The drawer that slides up ─────────────────────────────
    PanelWindow {
        id: drawer

        readonly property int drawerHeight: 360

        anchors {
            left: true
            right: true
            bottom: true
        }

        // Sit just above the taskbar
        margins.bottom: taskbar.implicitHeight
        implicitHeight: drawerHeight

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        // Float above normal windows
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.drawerOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        // Click-through except over the drawer surface itself
        mask: Region { item: drawerSurface }

        Rectangle {
            id: drawerSurface

            anchors.left: parent.left
            anchors.right: parent.right
            height: drawer.drawerHeight

            // Slide: hidden below window when closed, visible when open
            y: root.drawerOpen ? 0 : drawer.drawerHeight

            color: "#1a1b26"
            topLeftRadius: 16
            topRightRadius: 16

            Behavior on y {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutCubic
                }
            }

            // Drag handle indicator
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10
                width: 40
                height: 4
                radius: 2
                color: "#444b6a"
            }

            Text {
                anchors.centerIn: parent
                text: "Drawer content goes here"
                color: "#a9b1d6"
                font.pixelSize: 18
            }
        }
    }
}
