pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property bool isLightMode: false

    property real cornerRadius: 12
    property real popupTransparency: 0.95

    property real spacingXS: 4
    property real spacingS: 8
    property real spacingM: 12
    property real spacingL: 16
    property real spacingXL: 24

    property real fontSizeSmall: 12
    property real fontSizeMedium: 14
    property real fontSizeLarge: 16
    property real fontSizeXLarge: 20

    property real iconSize: 24
    property real iconSizeSmall: 16
    property real iconSizeLarge: 32

    property string fontFamily: "Inter Variable"
    property string monoFontFamily: "Fira Code"
    property int fontWeight: Font.Normal

    property int shortDuration: 150
    property int shorterDuration: 100
    property int mediumDuration: 300

    property int standardEasing: Easing.OutCubic

    property int currentAnimationSpeed: 2
    property var expressiveCurves: ({
        "standard": [0.2, 0, 0, 1, 1, 1],
        "standardDecel": [0, 0, 0, 1, 1, 1],
    })
    property var expressiveDurations: ({
        "normal": 300,
        "expressiveDefaultSpatial": 500,
    })

    property int layerOutlineWidth: 1

    readonly property color surface: Qt.rgba(21/255, 18/255, 24/255, 1)
    readonly property color surfaceContainer: Qt.rgba(33/255, 31/255, 36/255, 1)
    readonly property color surfaceContainerLow: Qt.rgba(29/255, 27/255, 32/255, 1)
    readonly property color surfaceContainerHigh: Qt.rgba(44/255, 41/255, 47/255, 1)
    readonly property color surfaceContainerHighest: Qt.rgba(55/255, 52/255, 58/255, 1)
    readonly property color surfaceVariant: Qt.rgba(73/255, 69/255, 78/255, 1)
    readonly property color surfaceText: Qt.rgba(231/255, 224/255, 232/255, 1)
    readonly property color surfaceVariantText: Qt.rgba(203/255, 196/255, 207/255, 1)
    readonly property color surfaceLight: Qt.rgba(73/255, 69/255, 78/255, 0.1)
    readonly property color onSurface_38: Qt.rgba(231/255, 224/255, 232/255, 0.38)

    readonly property color primary: Qt.rgba(211/255, 188/255, 253/255, 1)
    readonly property color primaryContainer: Qt.rgba(80/255, 60/255, 116/255, 1)
    readonly property color primaryHover: Qt.rgba(211/255, 188/255, 253/255, 0.12)
    readonly property color primaryHoverLight: Qt.rgba(211/255, 188/255, 253/255, 0.08)
    readonly property color primaryPressed: Qt.rgba(211/255, 188/255, 253/255, 0.24)

    readonly property color secondary: Qt.rgba(205/255, 194/255, 219/255, 1)
    readonly property color tertiary: Qt.rgba(241/255, 183/255, 197/255, 1)

    readonly property color error: Qt.rgba(255/255, 180/255, 171/255, 1)
    readonly property color errorHover: Qt.rgba(255/255, 180/255, 171/255, 0.12)
    readonly property color warning: Qt.rgba(255/255, 152/255, 0/255, 1)
    readonly property color warningHover: Qt.rgba(255/255, 152/255, 0/255, 0.12)
    readonly property color success: Qt.rgba(76/255, 175/255, 80/255, 1)
    readonly property color info: Qt.rgba(33/255, 150/255, 243/255, 1)

    readonly property color outline: Qt.rgba(148/255, 143/255, 153/255, 1)
    readonly property color outlineVariant: Qt.rgba(73/255, 69/255, 78/255, 1)
    readonly property color outlineLight: withAlpha(outline, 0.075)
    readonly property color outlineMedium: withAlpha(outline, 0.12)
    readonly property color outlineStrong: withAlpha(outline, 0.18)

    readonly property color background: Qt.rgba(21/255, 18/255, 24/255, 1)
    readonly property color backgroundText: surfaceText

    readonly property color ccTileActiveBg: primary
    readonly property color ccPillInactiveBg: surfaceLight
    readonly property color ccPillInactiveHoverBg: primaryHover
    readonly property color buttonBg: primary
    readonly property color buttonText: Qt.rgba(57/255, 38/255, 92/255, 1)
    readonly property color buttonHover: primaryHover
    readonly property color buttonPressed: primaryPressed

    function withAlpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function blend(c1, c2, amount) {
        const t = Math.max(0, Math.min(1, amount));
        return Qt.rgba(
            c1.r + (c2.r - c1.r) * t,
            c1.g + (c2.g - c1.g) * t,
            c1.b + (c2.b - c1.b) * t,
            c1.a + (c2.a - c1.a) * t
        );
    }
}
