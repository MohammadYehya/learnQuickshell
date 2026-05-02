// shell.qml
import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    // Shared state — the taskbar button flips this, the drawer reads it
    property bool drawerOpen: false

    // ── The bottom taskbar ─────────────────────────────────────
    PanelWindow {
        id: taskbar

        anchors {
            left: true
            right: true
            bottom: true
        }
        implicitHeight: 48
        color: "#1a1b26"

        // The trigger button, centered in the taskbar
        Rectangle {
            id: triggerBtn
            anchors.centerIn: parent
            width: 120
            height: 32
            radius: 8
            color: triggerArea.containsMouse ? "#2a2b3d" : "#24253a"

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text: root.drawerOpen ? "Close" : "Open drawer"
                color: "#a9b1d6"
                font.pixelSize: 13
            }

            MouseArea {
                id: triggerArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.drawerOpen = !root.drawerOpen
            }
        }
    }

    // ── The drawer window ──────────────────────────────────────
    PanelWindow {
        id: drawer

        readonly property int drawerHeight: 360
        readonly property int taskbarHeight: 48

        // Span the full screen width so we can center the drawer surface
        anchors {
            left: true
            right: true
            bottom: true
        }
        // Total window height = drawer + taskbar gap so it sits *above* the bar
        implicitHeight: drawerHeight + taskbarHeight

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        // Only the drawer surface should capture clicks
        mask: Region { item: drawerSurface }

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: root.drawerOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        // The drawer surface: half-width, horizontally centered,
        // sitting just above the taskbar
        Rectangle {
            id: drawerSurface

            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width / 2
            height: drawer.drawerHeight

            // y position: when closed, push it below the screen;
            // when open, sit just above the taskbar (with a small gap)
            y: root.drawerOpen
                ? parent.height - drawer.drawerHeight - drawer.taskbarHeight - 8
                : parent.height

            color: "#1a1b26"
            radius: 16
            border.color: "#2a2b3d"
            border.width: 1

            // The fluid slide animation
            Behavior on y {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.OutCubic
                }
            }

            // Drag handle
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10
                width: 40
                height: 4
                radius: 2
                color: "#444b6a"
            }

            // Placeholder content
            Text {
                anchors.centerIn: parent
                text: "Drawer content"
                color: "#a9b1d6"
                font.pixelSize: 18
            }
        }
    }
}
