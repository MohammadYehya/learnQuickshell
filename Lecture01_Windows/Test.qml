// shell.qml
import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    PanelWindow {
        id: bar

        // ── State ─────────────────────────────────────────────
        property bool drawerOpen: false

        readonly property int barHeight: 44
        readonly property int drawerHeight: 320
        readonly property int drawerWidth: 480
        readonly property int sideMargin: 12

        // ── Window setup ──────────────────────────────────────
        anchors {
            left: true
            right: true
            bottom: true
        }

        // Window is tall enough to fit the drawer + bar, even
        // when closed — we just animate the inner shape
        implicitHeight: barHeight + drawerHeight + sideMargin

        color: "transparent"

        // Reserve only the bar's height as exclusive zone
        exclusiveZone: barHeight + sideMargin

        // Click-through everywhere except the bar/drawer surface
        mask: Region { item: surface }

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: drawerOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        // ── The unified surface ───────────────────────────────
        // This is one Rectangle that grows upward from the bar.
        // Bar portion stays fixed; drawer portion expands above.
        Rectangle {
            id: surface

            anchors.bottom: parent.bottom
            anchors.bottomMargin: bar.sideMargin
            anchors.horizontalCenter: parent.horizontalCenter

            // Width: bar is full width minus margins; drawer is narrower.
            // Animate between them — the surface morphs in place.
            width: bar.drawerOpen
                ? bar.drawerWidth
                : bar.width - (bar.sideMargin * 2)

            // Height: bar height when closed, bar+drawer when open
            height: bar.drawerOpen
                ? bar.barHeight + bar.drawerHeight
                : bar.barHeight

            color: "#1a1b26"
            radius: 18

            // The fluid morph — width and height ease together
            Behavior on width {
                NumberAnimation {
                    duration: 380
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: 380
                    easing.type: Easing.OutCubic
                }
            }

            // ── Drawer content (top portion) ──────────────────
            Item {
                id: drawerContent

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: bar.drawerHeight

                // Fade in as the drawer opens
                opacity: bar.drawerOpen ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Drawer"
                        color: "#a9b1d6"
                        font.pixelSize: 22
                        font.weight: 500
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Put quick toggles, calendar, or media here"
                        color: "#565f89"
                        font.pixelSize: 13
                    }
                }
            }

            // Subtle separator between drawer and bar (only visible when open)
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: barRow.top
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                height: 1
                color: "#2a2e42"
                opacity: bar.drawerOpen ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // ── Bar content (bottom portion, always visible) ──
            Item {
                id: barRow

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: bar.barHeight

                // The clickable trigger — centered on the bar
                Rectangle {
                    id: trigger

                    anchors.centerIn: parent
                    width: 120
                    height: 28
                    radius: 14
                    color: triggerArea.containsMouse
                        ? "#2a2e42"
                        : "transparent"

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: bar.drawerOpen ? "Close" : "Open drawer"
                        color: "#a9b1d6"
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: triggerArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: bar.drawerOpen = !bar.drawerOpen
                    }
                }

                // Left side — placeholder for workspaces, etc.
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: "● ● ●"
                    color: "#565f89"
                    font.pixelSize: 11
                }

                // Right side — placeholder for clock, tray, etc.
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    text: "12:34"
                    color: "#a9b1d6"
                    font.pixelSize: 13
                }
            }
        }
    }
}
