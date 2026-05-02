import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    PanelWindow {
        id: drawer
        property bool opened: false
        readonly property int drawerHeight: 360

        function toggle() { opened = !opened }

        anchors { left: true; right: true; bottom: true }
        implicitHeight: drawerHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        mask: Region { item: drawerSurface }
        WlrLayershell.layer: WlrLayer.Overlay

        // Toggle button
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 16
            width: 50; height: 50; radius: 8
            color: "#534AB7"
            Text { anchors.centerIn: parent; text: "☰"; color: "white"; font.pixelSize: 24 }
            MouseArea { anchors.fill: parent; onClicked: drawer.toggle() }
        }

        // The drawer itself
        Rectangle {
            id: drawerSurface
            anchors { left: parent.left; right: parent.right }
            height: drawer.drawerHeight
            y: drawer.opened ? 0 : drawer.drawerHeight
            color: "#1a1b26"
            topLeftRadius: 16
            topRightRadius: 16

            Behavior on y {
                NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
            }

            Text {
                anchors.centerIn: parent
                text: "← Swipe up or click button to close"
                color: "#a9b1d6"
                font.pixelSize: 16
            }

            DragHandler {
                yAxis.enabled: true
                target: drawerSurface
                onActiveChanged: {
                    if (!active && drawerSurface.y > drawer.drawerHeight * 0.3) {
                        drawer.opened = false
                    }
                }
            }
        }
    }
}
