import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: drawer

    // ── Public API ────────────────────────────────────────────
    property bool opened: false
    readonly property int drawerHeight: 360

    function toggle() { opened = !opened }
    function open()   { opened = true }
    function close()  { opened = false }

    // ── Window setup ──────────────────────────────────────────
    anchors {
        left: true
        right: true
        bottom: true
    }
    implicitHeight: drawerHeight

    // Transparent so the drawer can have rounded corners and
    // the area above it stays click-through
    color: "transparent"

    // Don't reserve screen space — drawer floats over content
    exclusionMode: ExclusionMode.Ignore

    // Allow clicks through everywhere except the drawer itself
    mask: Region { item: drawerSurface }

    // Layer config — drawer should be above normal windows
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: opened
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    // ── The drawer surface ────────────────────────────────────
    Rectangle {
        id: drawerSurface

        anchors.left: parent.left
        anchors.right: parent.right
        height: drawer.drawerHeight

        // Slide: when closed, sit fully below the window;
        // when opened, sit flush at the bottom
        y: drawer.opened ? 0 : drawer.drawerHeight

        color: "#1a1b26"
        topLeftRadius: 16
        topRightRadius: 16

        // The fluid motion — single Behavior, single source of truth
        Behavior on y {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }

        // ── Drag handle ───────────────────────────────────────
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            width: 40
            height: 4
            radius: 2
            color: "#444b6a"
        }

        // ── Drawer content goes here ──────────────────────────
        Text {
            anchors.centerIn: parent
            text: "Drawer content"
            color: "#a9b1d6"
            font.pixelSize: 18
        }

        // Optional: drag-to-dismiss
        DragHandler {
            id: dragHandler
            yAxis.enabled: true
            xAxis.enabled: false
            yAxis.minimum: 0
            yAxis.maximum: drawer.drawerHeight
            target: drawerSurface

            onActiveChanged: {
                if (!active) {
                    // If user dragged more than 30% down, close it
                    drawer.opened = drawerSurface.y < drawer.drawerHeight * 0.3
                }
            }
        }
    }
}
