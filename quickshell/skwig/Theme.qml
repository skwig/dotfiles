import QtQuick

QtObject {
    required property string textFontFamily
    required property string iconFontFamily

    required property color specialBackground
    required property color specialForeground
    required property color specialCursor

    required property color color0
    required property color color1
    required property color color2
    required property color color3
    required property color color4
    required property color color5
    required property color color6
    required property color color7
    required property color color8
    required property color color9
    required property color color10
    required property color color11
    required property color color12
    required property color color13
    required property color color14
    required property color color15

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
