pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    enum TextRenderType {
        Native,
        Qt,
        Curve
    }

    enum TextRenderQuality {
        Default,
        Low,
        Normal,
        High,
        VeryHigh
    }

    enum AnimationSpeed {
        None,
        Short,
        Medium,
        Long,
        Custom
    }

    property int textRenderType: SettingsData.TextRenderType.Native
    property int textRenderQuality: SettingsData.TextRenderQuality.Default
    property bool enableRippleEffects: true
    property real popupTransparency: 0.95
    property real cornerRadius: 12
    property real barHeight: 44
}
