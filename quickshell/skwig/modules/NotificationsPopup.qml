import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import ".."

PopupWindow {
    id: root

    required property Theme theme
    property Item anchorItem: null
    required property var notificationService

    readonly property int notificationCount: notificationService.notificationCount
    readonly property var groups: notificationService.groupedNotifications()

    anchor.item: anchorItem
    anchor.rect.x: anchorItem ? anchorItem.width / 2 - implicitWidth / 2 : 0
    anchor.rect.y: anchorItem ? anchorItem.height + 4 : 0

    implicitWidth: 420
    implicitHeight: Math.min(520, content.implicitHeight + 20)
    visible: false
    grabFocus: true
    color: "transparent"

    Rectangle {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        implicitHeight: column.implicitHeight + 24
        color: Qt.rgba(0, 0, 0, 0.8)
        radius: root.theme.radius

        Column {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 10

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                text: "Notifications"
                color: root.theme.fontColor
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Qt.rgba(1, 1, 1, 0.15)
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: root.notificationCount === 0
                text: "No notifications"
                color: Qt.rgba(1, 1, 1, 0.45)
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 2
            }

            Flickable {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: root.notificationCount > 0
                implicitHeight: Math.min(430, notificationGroups.implicitHeight)
                contentHeight: notificationGroups.implicitHeight
                clip: true

                Column {
                    id: notificationGroups
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 10

                    Repeater {
                        model: root.groups

                        delegate: Column {
                            id: groupColumn

                            required property var modelData

                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 6

                            Text {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                text: groupColumn.modelData.name + " (" + groupColumn.modelData.notifications.length + ")"
                                color: Qt.rgba(1, 1, 1, 0.6)
                                elide: Text.ElideRight
                                font.family: root.theme.font.family
                                font.pixelSize: root.theme.font.pixelSize - 3
                            }

                            Repeater {
                                model: groupColumn.modelData.notifications

                                delegate: Rectangle {
                                    id: notificationRow

                                    required property Notification modelData

                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    implicitHeight: Math.max(rowContent.implicitHeight, 32) + 14
                                    radius: root.theme.radius
                                    color: rowHover.hovered ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(1, 1, 1, 0.05)

                                    HoverHandler {
                                        id: rowHover
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: notificationRow.modelData.dismiss()
                                    }

                                    Row {
                                        id: rowContent
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: 8
                                        spacing: 8

                                        Item {
                                            width: 32
                                            height: 32
                                            anchors.verticalCenter: parent.verticalCenter

                                            IconImage {
                                                anchors.fill: parent
                                                visible: notificationRow.modelData.appIcon.length > 0
                                                source: Quickshell.iconPath(notificationRow.modelData.appIcon)
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                visible: notificationRow.modelData.appIcon.length === 0
                                                text: "󰂚"
                                                color: Qt.rgba(1, 1, 1, 0.6)
                                                font.family: root.theme.font.family
                                                font.pixelSize: root.theme.font.pixelSize
                                            }
                                        }

                                        Column {
                                            id: rowColumn
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width - 40
                                            spacing: 4

                                            Row {
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                spacing: 8

                                                Text {
                                                    width: parent.width - timeText.implicitWidth - parent.spacing
                                                    text: root.notificationService.notificationTitle(notificationRow.modelData)
                                                    color: root.theme.fontColor
                                                    elide: Text.ElideRight
                                                    font.family: root.theme.font.family
                                                    font.pixelSize: root.theme.font.pixelSize - 2
                                                }

                                                Text {
                                                    id: timeText
                                                    text: root.notificationService.relativeTime(notificationRow.modelData)
                                                    color: Qt.rgba(1, 1, 1, 0.45)
                                                    font.family: root.theme.font.family
                                                    font.pixelSize: root.theme.font.pixelSize - 4
                                                }
                                            }

                                            Text {
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                visible: notificationRow.modelData.body.length > 0 && notificationRow.modelData.summary.length > 0
                                                text: notificationRow.modelData.body
                                                textFormat: Text.PlainText
                                                maximumLineCount: 3
                                                wrapMode: Text.WordWrap
                                                elide: Text.ElideRight
                                                color: Qt.rgba(1, 1, 1, 0.6)
                                                font.family: root.theme.font.family
                                                font.pixelSize: root.theme.font.pixelSize - 4
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
