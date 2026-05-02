import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    property bool drawerOpen: false

    readonly property color surfaceColor: "#1a1b26"
    readonly property int cornerRadius: 16

    // ── Taskbar ───────────────────────────────────────────────
    PanelWindow {
        id: bar

        anchors { left: true; right: true; bottom: true }
        implicitHeight: 48
        color: root.surfaceColor
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

    // ── Drawer window ─────────────────────────────────────────
    PanelWindow {
        id: drawerWindow

        readonly property int drawerWidth: 480
        readonly property int drawerHeight: 320

        anchors { left: true; right: true; bottom: true }
        margins.bottom: bar.implicitHeight
        implicitHeight: drawerHeight

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.drawerOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        mask: Region { item: drawerSurface }

        // The drawer body — all four corners rounded
        Rectangle {
            id: drawerSurface

            width: drawerWindow.drawerWidth
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            color: root.surfaceColor
            radius: root.cornerRadius
            clip: true

            height: root.drawerOpen ? drawerWindow.drawerHeight : 0

            Behavior on height {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.OutCubic
                }
            }

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

        // ── Left inverse fillet ───────────────────────────────
        // Sits just outside the drawer's bottom-left corner.
        // Filled with bar color, with a quarter-circle carved out,
        // so the bar appears to curve up into the drawer.
        Canvas {
            width: root.cornerRadius
            height: root.cornerRadius
            x: drawerSurface.x - width
            y: drawerSurface.y + drawerSurface.height - height
            visible: drawerSurface.height > 0

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = root.surfaceColor;
                ctx.fillRect(0, 0, width, height);
                ctx.globalCompositeOperation = "destination-out";
                ctx.beginPath();
                ctx.arc(width, 0, width, 0, Math.PI * 2);
                ctx.fill();
            }
        }

        // ── Right inverse fillet ──────────────────────────────
        Canvas {
            width: root.cornerRadius
            height: root.cornerRadius
            x: drawerSurface.x + drawerSurface.width
            y: drawerSurface.y + drawerSurface.height - height
            visible: drawerSurface.height > 0

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                ctx.fillStyle = root.surfaceColor;
                ctx.fillRect(0, 0, width, height);
                ctx.globalCompositeOperation = "destination-out";
                ctx.beginPath();
                ctx.arc(0, 0, width, 0, Math.PI * 2);
                ctx.fill();
            }
        }
    }
}
