import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    // Shared state — single source of truth for the drawer
    property bool drawerOpen: false

    // Shared design tokens
    readonly property color surfaceColor: "#1a1b26"
    readonly property int cornerRadius: 16

    // ── The taskbar ───────────────────────────────────────────
    PanelWindow {
        id: bar

        anchors {
            left: true
            right: true
            bottom: true
        }
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

        implicitHeight: drawerHeight

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.drawerOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        // Mask covers drawer surface plus the inverse corners
        mask: Region {
            item: drawerSurface
        }

        // ── Drawer surface ────────────────────────────────────
        Rectangle {
            id: drawerSurface

            width: drawerWindow.drawerWidth
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            color: root.surfaceColor

            // Round all four corners now — bottom curves outward into the bar
            radius: root.cornerRadius

            height: root.drawerOpen ? drawerWindow.drawerHeight : 0

            Behavior on height {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.OutCubic
                }
            }

            clip: true

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

        // ── Inverse corner pieces (the "fillets") ─────────────
        // These sit just outside the drawer's bottom corners, on the bar.
        // Each is a square the size of the radius, filled with the bar
        // color, with a transparent quarter-circle carved out of it.
        // The visual effect: the bar curves up into the drawer.

        // Left fillet
        Item {
            width: root.cornerRadius
            height: root.cornerRadius
            x: drawerSurface.x - width
            y: drawerSurface.y + drawerSurface.height - height

            // Only show fillets when the drawer is actually visible
            visible: drawerSurface.height > 0

            Rectangle {
                anchors.fill: parent
                color: root.surfaceColor
            }

            // Carve out the quarter-circle using a Rectangle whose
            // border draws an arc, then mask it. Simpler approach:
            // draw a circle larger than the square, offset so only
            // the corner of the circle "eats into" our square.
            Rectangle {
                width: parent.width * 2
                height: parent.height * 2
                radius: width / 2
                color: "transparent"
                // Position so the circle's bottom-right corner aligns
                // with our top-left — this makes the visible quarter
                // appear in the top-left of the parent
                x: -parent.width
                y: -parent.height

                // Use a border-only ring won't work; we need a real
                // cut-out. Instead, layer effects:
                layer.enabled: true
                layer.samples: 4
            }

            // Cleaner approach: use a Canvas to paint the exact shape
            Canvas {
                anchors.fill: parent
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = root.surfaceColor;
                    // Fill the whole square
                    ctx.fillRect(0, 0, width, height);
                    // Carve out the top-right quarter circle
                    ctx.globalCompositeOperation = "destination-out";
                    ctx.beginPath();
                    ctx.arc(width, 0, width, 0, Math.PI * 2);
                    ctx.fill();
                }
            }
        }

        // Right fillet
        Item {
            width: root.cornerRadius
            height: root.cornerRadius
            x: drawerSurface.x + drawerSurface.width
            y: drawerSurface.y + drawerSurface.height - height

            visible: drawerSurface.height > 0

            Canvas {
                anchors.fill: parent
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    ctx.fillStyle = root.surfaceColor;
                    ctx.fillRect(0, 0, width, height);
                    ctx.globalCompositeOperation = "destination-out";
                    ctx.beginPath();
                    // Carve out the top-left quarter circle
                    ctx.arc(0, 0, width, 0, Math.PI * 2);
                    ctx.fill();
                }
            }
        }
    }
}
