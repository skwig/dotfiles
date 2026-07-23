import QtQuick

QtObject {
    property string textFontFamily: "Inter"
    property string iconFontFamily: "Material Symbols Rounded"

    property color specialBackground: "#190b11"
    property color specialForeground: "#c5c2c3"
    property color specialCursor: "#c5c2c3"

    property color color0: "#190b11"
    property color color1: "#75658E"
    property color color2: "#8F6A87"
    property color color3: "#A67A8F"
    property color color4: "#CC6CA1"
    property color color5: "#A288A8"
    property color color6: "#C8919C"
    property color color7: "#c5c2c3"
    property color color8: "#6e5a63"
    property color color9: "#75658E"
    property color color10: "#8F6A87"
    property color color11: "#A67A8F"
    property color color12: "#CC6CA1"
    property color color13: "#A288A8"
    property color color14: "#C8919C"
    property color color15: "#c5c2c3"

    property color background: specialBackground
    property color onSurface: specialForeground
    property color onSurfaceVariant: color5
    property color muted: withAlpha(specialForeground, 0.62)
    property color primary: color4
    property color onPrimary: specialForeground
    property color primaryContainer: color1
    property color onPrimaryContainer: color15
    property color secondary: color5
    property color tertiary: color6
    property color surface: Qt.tint(color0, Qt.rgba(color4.r, color4.g, color4.b, 0.05))
    property color surfaceContainer: Qt.tint(color0, Qt.rgba(color4.r, color4.g, color4.b, 0.10))
    property color surfaceContainerHigh: Qt.tint(color0, Qt.rgba(color5.r, color5.g, color5.b, 0.14))
    property color surfaceContainerHighest: Qt.tint(color0, Qt.rgba(color7.r, color7.g, color7.b, 0.12))
    property color surfaceVariant: Qt.tint(color0, Qt.rgba(color8.r, color8.g, color8.b, 0.22))
    property color outline: color8
    property color outlineVariant: withAlpha(color8, 0.55)
    property color error: "#ffb4ab"
    property color warning: color3
    property color success: color2

    property color fontColor: onSurface
    property real radius: 14
    property real radiusLarge: 22
    property real radiusFull: 999
    property real spacingXS: 4
    property real spacingS: 8
    property real spacingM: 12
    property real spacingL: 16
    property real spacingXL: 24
    property real iconSizeSmall: 16
    property real iconSize: 22
    property real iconSizeLarge: 28
    property int shortDuration: 140
    property int mediumDuration: 220
    property int emphasizedEasing: Easing.OutCubic

    property font font: Qt.font({
        family: textFontFamily,
        pixelSize: 14
    })
    property font fontSmall: Qt.font({
        family: textFontFamily,
        pixelSize: 12
    })
    property font fontTiny: Qt.font({
        family: textFontFamily,
        pixelSize: 11
    })

    function withAlpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }
}
