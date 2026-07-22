import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import ".."

PanelWindow {
    id: root

    required property Theme theme
    required property var notificationService
    property ShellScreen targetScreen: null

    anchors.top: true
    anchors.right: true
    screen: targetScreen
    margins.top: 12
    margins.right: 12
    exclusiveZone: 0
    implicitWidth: 360
    implicitHeight: stack.implicitHeight
    visible: notificationService.osdNotifications.length > 0
    color: "transparent"

    Column {
        id: stack
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 8

        Repeater {
            model: root.notificationService.osdNotifications

            delegate: Rectangle {
                id: card

                required property Notification modelData
                readonly property string appIcon: modelData.appIcon
                readonly property bool hasAppIcon: appIcon.length > 0

                width: root.implicitWidth
                implicitHeight: Math.max(content.implicitHeight + 20, 64)
                radius: root.theme.radius
                color: hover.hovered ? Qt.rgba(0.08, 0.08, 0.08, 0.92) : Qt.rgba(0, 0, 0, 0.86)

                Component.onCompleted: hideTimer.restart()

                HoverHandler {
                    id: hover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: card.modelData.dismiss()
                }

                Timer {
                    id: hideTimer
                    interval: 5000
                    onTriggered: root.notificationService.removeFromOsd(card.modelData)
                }

                Row {
                    id: content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 10
                    spacing: 10

                    Item {
                        width: 40
                        height: 40
                        anchors.verticalCenter: parent.verticalCenter

                        IconImage {
                            anchors.fill: parent
                            visible: card.hasAppIcon
                            source: Quickshell.iconPath(card.appIcon)
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !card.hasAppIcon
                            text: "󰂚"
                            color: Qt.rgba(1, 1, 1, 0.65)
                            font.family: root.theme.font.family
                            font.pixelSize: root.theme.font.pixelSize + 4
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 50
                        spacing: 3

                        Text {
                            width: parent.width
                            text: root.notificationService.appName(card.modelData)
                            color: Qt.rgba(1, 1, 1, 0.55)
                            elide: Text.ElideRight
                            font.family: root.theme.font.family
                            font.pixelSize: root.theme.font.pixelSize - 4
                        }

                        Text {
                            width: parent.width
                            text: root.notificationService.notificationTitle(card.modelData)
                            color: root.theme.fontColor
                            elide: Text.ElideRight
                            font.family: root.theme.font.family
                            font.pixelSize: root.theme.font.pixelSize - 2
                        }

                        Text {
                            width: parent.width
                            visible: card.modelData.body.length > 0 && card.modelData.summary.length > 0
                            text: card.modelData.body
                            textFormat: Text.PlainText
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            color: Qt.rgba(1, 1, 1, 0.65)
                            font.family: root.theme.font.family
                            font.pixelSize: root.theme.font.pixelSize - 4
                        }
                    }
                }
            }
        }
    }
}
