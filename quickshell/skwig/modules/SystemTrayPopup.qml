import QtQuick
import Quickshell
import Quickshell.Services.SystemTray as Tray
import ".." as Root
import "../components" as Components

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

    Components.MaterialPopupSurface {
        id: content
        theme: root.theme
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10
        contentPadding: root.theme.spacingM
        implicitWidth: row.implicitWidth + contentPadding * 2
        implicitHeight: row.implicitHeight + contentPadding * 2

        Row {
            id: row
            anchors.left: parent.left
            anchors.top: parent.top
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
                        radius: root.theme.radiusFull
                        color: itemHover.hovered ? root.theme.surfaceContainerHighest : "transparent"

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
                color: root.theme.muted
                font: root.theme.fontSmall
            }
        }
    }
}
