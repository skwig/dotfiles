import QtQuick
import Quickshell
import Quickshell.Services.Notifications

PopupWindow {
    id: root

    required property Theme theme
    required property Item anchorItem

    readonly property var notifications: server.trackedNotifications.values
    readonly property int notificationCount: notifications.length
    readonly property var groups: groupedNotifications()

    property var receivedTimes: ({})

    anchor.item: anchorItem
    anchor.rect.x: anchorItem.width / 2 - implicitWidth / 2
    anchor.rect.y: anchorItem.height + 4

    implicitWidth: 420
    implicitHeight: Math.min(520, content.implicitHeight + 20)
    visible: false
    color: "transparent"

    NotificationServer {
        id: server

        bodySupported: true
        bodyMarkupSupported: false
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            root.receivedTimes[root.notificationKey(notification)] = Date.now();
            notification.tracked = true;
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    function notificationKey(notification) {
        return [notification.appName, notification.id, notification.summary, notification.body].join("|");
    }

    function receivedTime(notification) {
        const key = notificationKey(notification);
        if (!root.receivedTimes[key])
            root.receivedTimes[key] = Date.now();
        return root.receivedTimes[key];
    }

    function appName(notification) {
        return notification.appName || notification.desktopEntry || "Unknown";
    }

    function relativeTime(notification) {
        const seconds = Math.max(0, Math.floor((clock.date.getTime() - receivedTime(notification)) / 1000));
        if (seconds < 60)
            return "now";
        const minutes = Math.floor(seconds / 60);
        if (minutes < 60)
            return minutes + "m";
        const hours = Math.floor(minutes / 60);
        if (hours < 24)
            return hours + "h";
        return Math.floor(hours / 24) + "d";
    }

    function notificationTitle(notification) {
        return notification.summary || notification.body || "Notification";
    }

    function groupedNotifications() {
        const map = new Map();
        for (const notification of root.notifications) {
            const name = root.appName(notification);
            if (!map.has(name))
                map.set(name, []);
            map.get(name).push(notification);
        }

        const groups = [];
        for (const [name, items] of map.entries()) {
            const sortedItems = items.sort((a, b) => root.receivedTime(b) - root.receivedTime(a));
            groups.push({
                name: name,
                notifications: sortedItems,
                newest: sortedItems.length > 0 ? root.receivedTime(sortedItems[0]) : 0
            });
        }

        return groups.sort((a, b) => b.newest - a.newest);
    }

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
                                    implicitHeight: rowColumn.implicitHeight + 14
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

                                    Column {
                                        id: rowColumn
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.margins: 8
                                        spacing: 4

                                        Row {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            spacing: 8

                                            Text {
                                                width: parent.width - timeText.implicitWidth - parent.spacing
                                                text: root.notificationTitle(notificationRow.modelData)
                                                color: root.theme.fontColor
                                                elide: Text.ElideRight
                                                font.family: root.theme.font.family
                                                font.pixelSize: root.theme.font.pixelSize - 2
                                            }

                                            Text {
                                                id: timeText
                                                text: root.relativeTime(notificationRow.modelData)
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
