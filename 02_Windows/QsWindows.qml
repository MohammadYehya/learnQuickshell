import Quickshell
import QtQuick
// These are the base modules that you have to import to use the quickshell functionalities.

// This is the base class that all windows inherit from
// QsWindow
// It has the following attributes:
// - visible (bool) (Show or hide the window)
// - color (color) (Window background. Use "transparent" for a see-through shell)
// - screen (ShellScreen) (The monitor this window belongs to. Bind the modelData inside a Variants loop)
// - mask (Region) (Composable mask for click-through regions - clicks outside the mask pass to underlying windows)
// - implicitWidth/implicitHeight (int) (Desired size. Actual size may differ, e.g. anchors stretch a PanelWindow)
// - width/height (int READ ONLY) (Actual rendered size. Read from these; write to implicit*)
