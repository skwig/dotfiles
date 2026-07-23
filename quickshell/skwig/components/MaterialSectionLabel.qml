import QtQuick
import ".." as Root

Text {
    required property Root.Theme theme

    color: theme.muted
    font.family: theme.fontTiny.family
    font.pixelSize: theme.fontTiny.pixelSize
    font.bold: true
    font.letterSpacing: 0.6
    elide: Text.ElideRight
}
