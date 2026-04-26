import Quickshell
import QtQuick

// This window is a transient popup window that attaches to another item via PopupAnchor.
// It has the following specific attributes:
// - visible (bool) (Toggle the popup open/closed)
// - anchor (PopupAnchor) (Inline object with item, onItem, onParent edgesm and adjustment strategies)
// The object contains the following:
// - anchor.window (the parent window to position relative to. Mutually exclusive with anchor.item)
// - anchor.item (a specific QML Item to attach to)
// - anchor.edges (which corner of the anchor rect the popup attaches to. Uses Edges.Top, Edges.Bottom, Edges.Right, Edges.Left)
// - anchor.gravity (which direction the popup expands from the anchor point)
// - anchor.margins (pixel offset applied to the anchor rect)
// - anchor.adjustment (what to do when the popup would go off-screen. The PopupAdjustment values are None, Slide, Flip, All)
PanelWindow {
	id: bar
	anchors {bottom: true; left: true; right: true}
	implicitHeight: 30

	Rectangle {
		id: btn
		width: 80; height: 30
		color: "#444"
		anchors.centerIn: parent

		MouseArea {
			anchors.fill: parent
			onClicked: popup.visible = !popup.visible
		}

		Text {anchors.centerIn: parent; text: "Click me"; color: "white"}
	}	

	PopupWindow {
		id: popup
		anchor.item: btn
		anchor.edges: Edges.Top
		anchor.gravity: Edges.Top
		anchor.adjustment: PopupAdjustment.Flip
		implicitWidth: 160
		implicitHeight: 100
		visible: false
		color: "#2a2a3a"

		Text {anchors.centerIn: parent; text: "Popup Content"; color: "white"}
	}
}
