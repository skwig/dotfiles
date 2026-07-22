import QtQuick
import Quickshell
import Quickshell.Services.SystemTray as Tray
import ".." as Root

PopupWindow {
    id: root

    required property Root.Theme theme
    property Item anchorItem: null

    readonly property var items: Tray.SystemTray.items.values

    anchor.item: anchorItem
    anchor.rect.x: 0
    anchor.rect.y: anchorItem ? anchorItem.height + 4 : 0

    implicitWidth: Math.max(56, content.implicitWidth + 20)
    implicitHeight: content.implicitHeight + 20
    visible: false
    grabFocus: true
    color: "transparent"

    Rectangle {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        implicitWidth: row.implicitWidth + 24
        implicitHeight: row.implicitHeight + 24
        color: Qt.rgba(0, 0, 0, 0.8)
        radius: root.theme.radius

        Row {
            id: row
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 6

            Repeater {
                model: root.items

                delegate: Item {
                    id: trayItem

                    required property Tray.SystemTrayItem modelData

                    implicitWidth: 28
                    implicitHeight: 28

                    Rectangle {
                        anchors.fill: parent
                        radius: root.theme.radius
                        color: itemHover.hovered ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                        HoverHandler {
                            id: itemHover
                        }

                        Image {
                            anchors.centerIn: parent
                            width: 18
                            height: 18
                            source: trayItem.modelData.icon
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        MouseArea {
                            id: clickArea

                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            cursorShape: Qt.PointingHandCursor

                            onClicked: event => {
                                if (event.button === Qt.LeftButton) {
                                    if (trayItem.modelData.onlyMenu && trayItem.modelData.hasMenu)
                                        menuAnchor.open();
                                    else
                                        trayItem.modelData.activate();
                                } else if (event.button === Qt.RightButton) {
                                    if (trayItem.modelData.hasMenu)
                                        menuAnchor.open();
                                    else
                                        trayItem.modelData.secondaryActivate();
                                } else if (event.button === Qt.MiddleButton) {
                                    trayItem.modelData.secondaryActivate();
                                }
                            }
                        }

                        QsMenuAnchor {
                            id: menuAnchor
                            menu: trayItem.modelData.menu
                            anchor.item: clickArea
                        }
                    }
                }
            }

            Text {
                visible: root.items.length === 0
                text: "No tray items"
                color: Qt.rgba(1, 1, 1, 0.45)
                font.family: root.theme.font.family
                font.pixelSize: root.theme.font.pixelSize - 2
            }
        }
    }
}
