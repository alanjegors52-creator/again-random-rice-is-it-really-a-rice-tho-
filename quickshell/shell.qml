// shell.qml  —  Quickshell entry point
// Pins the orbital clock fullscreen to the desktop layer (behind all windows).
// Transparent window: only the clock elements are drawn.
//
// File layout:
//   ~/.config/quickshell/orbital-clock/
//   ├── shell.qml          ← this file
//   ├── OrbitalClock.qml
//   └── font/
//       └── Outfit-Black.ttf

import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    // One panel per screen — remove the `screen` filter below
    // if you only want it on your primary display.
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData

            screen: modelData

            // Stretch to cover the full screen
            anchors { top: true; bottom: true; left: true; right: true }

            // Sit behind every other window
            WlrLayershell.layer:         WlrLayer.Bottom
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            // Don't push taskbars / docks out of the way
            exclusionMode: ExclusionMode.Ignore

            // Transparent window — the clock draws itself, nothing else
            color: "transparent"

            OrbitalClock {
                anchors.fill: parent
                themeMode:    "dark"   // "dark" | "light"
                // clockScale auto-derives from height, no need to set it
            }
        }
    }
}
