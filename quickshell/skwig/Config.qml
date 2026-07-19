pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property font fontBase: ({
            family: fontFamily,
            pixelSize: 13
        })
    readonly property color fontColor: "#ffffff"
}
