import Quickshell
import QtQuick

// This creates a decoration-less window that anchors to screen edges and can reserve exclusive screen space.
PanelWindow {
	anchors {top: true; left: true; right: true}
	implicitHeight: 26
	color: "#1a1b26"
	exclusionMode: ExclusionMode.Auto
}
