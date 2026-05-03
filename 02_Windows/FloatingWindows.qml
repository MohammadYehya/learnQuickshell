import Quickshell
import QtQuick

// This is a window that doesn't dock against a side, and doesn't reserve any space.
// This is similar to an app view.
// It has the following specific attribtues:
// - minimumWidth/minimumHeight (int) (Minimum resize dimensions)
// - title (string) (Window title shown in the title bar and taskbar)
FloatingWindow {
	title: "First Box"	// Specific Attribute
	visible: true
	implicitWidth: 200
	implicitHeight: 100

	Text {anchors.centerIn: parent; text: "Content"}
}
