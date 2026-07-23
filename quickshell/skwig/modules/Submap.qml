import QtQuick
import Quickshell.Hyprland
import Quickshell.Io
import ".." as Root

Item {
    id: root

    required property Root.Theme theme
    property bool hideWhenDefault: false
    property string defaultSubmap: "reset"
    property var windowClassSubmaps: ({
        ".qemu-system-x86_64-wrapped": "vm",
        "Vmware": "vm"
    })

    property string currentSubmap: defaultSubmap
    readonly property bool hasSubmap: currentSubmap.length > 0
    readonly property bool isDefaultSubmap: currentSubmap === defaultSubmap

    anchors.verticalCenter: parent.verticalCenter
    visible: hasSubmap && !(hideWhenDefault && isDefaultSubmap)
    implicitWidth: visible ? Math.min(content.implicitWidth + 20, 170) : 0
    implicitHeight: content.implicitHeight + 10

    Component.onCompleted: activeWindowProcess.running = true

    function displayName(value) {
        return (value || "").trim();
    }

    function submapFromEvent(data) {
        const submap = root.displayName(data);
        return submap.length > 0 ? submap : root.defaultSubmap;
    }

    function submapForWindow(window) {
        if (!window)
            return root.defaultSubmap;

        const className = root.displayName(window.class || "");
        const initialClass = root.displayName(window.initialClass || "");
        return root.windowClassSubmaps[className] || root.windowClassSubmaps[initialClass] || root.defaultSubmap;
    }

    Rectangle {
        anchors.fill: parent
        radius: root.theme.radius
        color: hoverHandler.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

        HoverHandler {
            id: hoverHandler
        }

        Row {
            id: content
            anchors.centerIn: parent
            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "keyboard_command_key"
                color: root.theme.onSurface
                font.family: root.theme.iconFontFamily
                font.pixelSize: root.theme.iconSizeSmall
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, 120)
                text: root.currentSubmap
                color: root.theme.onSurface
                font: root.theme.fontSmall
                elide: Text.ElideRight
            }
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name === "submap")
                root.currentSubmap = root.submapFromEvent(event.data);
        }
    }

    Process {
        id: activeWindowProcess
        running: false
        command: ["hyprctl", "-j", "activewindow"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.currentSubmap = root.submapForWindow(JSON.parse(text));
                } catch (error) {
                    root.currentSubmap = root.defaultSubmap;
                }
            }
        }
    }
}
