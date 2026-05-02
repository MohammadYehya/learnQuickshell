import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes

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
        // How far the curve flares outward into the bar at the bottom corners
        readonly property int flareRadius: 24
        // Top corner radius (convex — rounded outward)
        readonly property int topRadius: 16

        anchors {
            left: true
            right: true
            bottom: true
        }

        margins.bottom: bar.implicitHeight

        implicitHeight: drawerHeight

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.drawerOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        mask: Region { item: drawerShape }

        // ── The custom-shaped drawer surface ──────────────────
        Shape {
            id: drawerShape

            // Width includes the flare on each side, so visually
            // the "main" drawer is drawerWidth wide and the flare
            // extends beyond it
            width: drawerWindow.drawerWidth + (drawerWindow.flareRadius * 2)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom

            // Animated height — grows upward from the bar
            height: root.drawerOpen ? drawerWindow.drawerHeight : 0

            Behavior on height {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.OutCubic
                }
            }

            clip: true
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeWidth: 0
                strokeColor: "transparent"
                fillColor: "#1a1b26"

                // Geometry shorthand
                readonly property real w: drawerShape.width
                readonly property real h: drawerShape.height
                readonly property real flare: drawerWindow.flareRadius
                readonly property real top: drawerWindow.topRadius

                // Start at bottom-left of the flared base
                startX: 0
                startY: h

                // Concave curve flaring inward and up to the drawer body
                PathArc {
                    x: drawerShape.shapeBottomLeftX
                    y: drawerShape.shapeBottomLeftY
                    radiusX: drawerWindow.flareRadius
                    radiusY: drawerWindow.flareRadius
                    direction: PathArc.Counterclockwise
                }

                // Up the left side of the drawer body
                PathLine {
                    x: drawerShape.shapeBottomLeftX
                    y: drawerWindow.topRadius
                }

                // Top-left convex rounded corner
                PathArc {
                    x: drawerShape.shapeBottomLeftX + drawerWindow.topRadius
                    y: 0
                    radiusX: drawerWindow.topRadius
                    radiusY: drawerWindow.topRadius
                    direction: PathArc.Clockwise
                }

                // Across the top
                PathLine {
                    x: drawerShape.shapeBottomRightX - drawerWindow.topRadius
                    y: 0
                }

                // Top-right convex rounded corner
                PathArc {
                    x: drawerShape.shapeBottomRightX
                    y: drawerWindow.topRadius
                    radiusX: drawerWindow.topRadius
                    radiusY: drawerWindow.topRadius
                    direction: PathArc.Clockwise
                }

                // Down the right side of the drawer body
                PathLine {
                    x: drawerShape.shapeBottomRightX
                    y: drawerShape.height - drawerWindow.flareRadius
                }

                // Concave curve flaring outward and down to the right edge
                PathArc {
                    x: drawerShape.width
                    y: drawerShape.height
                    radiusX: drawerWindow.flareRadius
                    radiusY: drawerWindow.flareRadius
                    direction: PathArc.Counterclockwise
                }

                // Close along the bottom back to startX, startY (handled implicitly)
                PathLine {
                    x: 0
                    y: drawerShape.height
                }
            }

            // Computed positions of the drawer body's bottom corners
            readonly property real shapeBottomLeftX: drawerWindow.flareRadius
            readonly property real shapeBottomLeftY: height - flareRadius
            readonly property real shapeBottomRightX: width - drawerWindow.flareRadius
            readonly property real shapeBottomRightY: height - flareRadius

            // ── Drawer content ────────────────────────────────
            Column {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -drawerWindow.flareRadius / 2
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
