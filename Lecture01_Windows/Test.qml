import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    // Shared state — single source of truth for the drawer
    property bool drawerOpen: false

    // ── The taskbar ───────────────────────────────────────────
    PanelWindow {
        id: bar

        anchors {
            left: true
            right: true
            bottom: true
        }
        implicitHeight: 48
        color: "#1a1b26"

        // Bar reserves its own space; drawer will not
        exclusionMode: ExclusionMode.Auto

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.drawerOpen = !root.drawerOpen
        }

        Text {
            anchors.centerIn: parent
            text: root.drawerOpen ? "▼ click to close" : "▲ click to open drawer"
            color: "#a9b1d6"
            font.pixelSize: 14
        }
    }

    // ── The drawer (separate window, sits above the bar) ──────
    PanelWindow {
        id: drawerWindow

        readonly property int drawerWidth: 480
        readonly property int drawerHeight: 320

        anchors {
            left: true
            right: true
            bottom: true
        }

        // Anchor above the bar so its bottom edge meets the bar's top edge
        margins.bottom: bar.implicitHeight

        // Window is tall enough to fit the drawer when fully extended
        implicitHeight: drawerHeight

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.drawerOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        // Only the drawer surface receives clicks; rest is click-through
        mask: Region { item: drawerSurface }

        Rectangle {
            id: drawerSurface

            // Half-width, centered horizontally
            width: drawerWindow.drawerWidth
            anchors.horizontalCenter: parent.horizontalCenter

            // Same color as the bar — visually they're one piece
            color: "#1a1b26"

            // Round only the top corners so the bottom merges into the bar
            topLeftRadius: 12
            topRightRadius: 12
            bottomLeftRadius: 0
            bottomRightRadius: 0

            // Pin to the bottom of the window (which sits on top of the bar)
            anchors.bottom: parent.bottom

            // Animate the height — grows upward from the bar
            height: root.drawerOpen ? drawerWindow.drawerHeight : 0

            Behavior on height {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.OutCubic
                }
            }

            // Hide overflow during the grow animation
            clip: true

            // ── Drawer content ────────────────────────────────
            Column {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Drawer"
                    color: "#a9b1d6"
                    font.pixelSize: 20
                    font.weight: 500
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Put widgets, launchers, or anything here"
                    color: "#565f89"
                    font.pixelSize: 13
                }
            }
        }
    }
}
