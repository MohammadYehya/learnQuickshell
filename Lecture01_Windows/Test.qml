import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    property bool drawerOpen: false
    readonly property color shellColor: "#1a1b26"
    readonly property int curveRadius: 18

    // ── The taskbar ───────────────────────────────────────────
    PanelWindow {
        id: bar

        anchors {
            left: true
            right: true
            bottom: true
        }
        implicitHeight: 48
        color: root.shellColor
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

    // ── The drawer ────────────────────────────────────────────
    PanelWindow {
    id: drawerWindow

    readonly property int drawerWidth: 480
    readonly property int drawerHeight: 320

    anchors {
        left: true
        right: true
        bottom: true
    }
    margins.bottom: bar.implicitHeight
    implicitHeight: drawerHeight + root.curveRadius

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.drawerOpen
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None

    mask: Region {
        item: drawerSurface
        Region { item: leftCurve }
        Region { item: rightCurve }
    }

    Item {
    id: drawerContainer
    width: drawerWindow.drawerWidth + root.curveRadius * 2
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom

    height: root.drawerOpen ? drawerWindow.drawerHeight : 0

    Behavior on height {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutCubic
        }
    }

    // ── Main drawer body ──────────────────────────────────────
    Rectangle {
        id: drawerSurface

        width: drawerWindow.drawerWidth
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        height: parent.height

        color: root.shellColor
        topLeftRadius: 12
        topRightRadius: 12
        bottomLeftRadius: 0
        bottomRightRadius: 0
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

    // ── Left concave curve — anchored to drawerSurface's bottom-left ──
    Canvas {
        id: leftCurve
        width: root.curveRadius
        height: root.curveRadius

        // Sit just outside the drawer's bottom-left corner
        anchors.right: drawerSurface.left
        anchors.bottom: drawerSurface.bottom

        // Hide once the drawer has collapsed enough that the curve
        // would extend below the bar's top edge
        visible: drawerSurface.height >= root.curveRadius

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = root.shellColor
            ctx.beginPath()
            ctx.moveTo(0, height)
            ctx.lineTo(width, height)
            ctx.lineTo(width, 0)
            ctx.arc(0, 0, width, 0, Math.PI / 2, false)
            ctx.closePath()
            ctx.fill()
        }
    }

    // ── Right concave curve — anchored to drawerSurface's bottom-right ──
    Canvas {
        id: rightCurve
        width: root.curveRadius
        height: root.curveRadius

        anchors.left: drawerSurface.right
        anchors.bottom: drawerSurface.bottom

        visible: drawerSurface.height >= root.curveRadius

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = root.shellColor
            ctx.beginPath()
            ctx.moveTo(0, height)
            ctx.lineTo(width, height)
            ctx.lineTo(0, 0)
            ctx.arc(width, 0, width, Math.PI / 2, Math.PI, false)
            ctx.closePath()
            ctx.fill()
        }
    }
}
}
}
