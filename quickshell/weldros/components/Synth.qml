import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
// import Qt5Compat.GraphicalEffects

PanelWindow {
  id: synth
  visible: root.synthVisible
  exclusionMode: ExclusionMode.Ignore
  anchors { top: true}
  margins { top:31}
  implicitWidth: 780
  implicitHeight: 260
  color: "transparent"
  focusable: false

  property var cavaValues: [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
  property string mediaText: ""
  property string mediaClass: "stopped"
  property real mediaPosition: 0
  property real mediaLength: 0

  component MediaBtn: Item {
    id: btnRoot
    property string icon: ""
    property int iconSize: 45
    signal clicked()

    implicitWidth: btnText.implicitWidth
    implicitHeight: btnText.implicitHeight

    Text {
      id: btnText
      anchors.centerIn: parent
      text: btnRoot.icon
      color: btnMA.containsMouse ? root.walColor2 : root.walForeground
      opacity: btnMA.containsMouse ? 0.8 : 0.3
      font.pixelSize: btnRoot.iconSize
      font.family: "JetBrainsMono Nerd Font"

      Behavior on opacity { NumberAnimation { duration: 150 } }
      Behavior on color { ColorAnimation { duration: 150 } }
    }

    MouseArea {
      id: btnMA
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: btnRoot.clicked()
    }
  }

  Timer {
    interval: 1500
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: { if (!mediaProc.running) mediaProc.running = true }
  }

  Process {
    id: mediaProc
    //command: ["bash", "-c", "status=$(playerctl --player=%any status 2>/dev/null); pos=$(playerctl --player=%any position 2>/dev/null | cut -d. -f1); len=$(playerctl --player=%any metadata mpris:length 2>/dev/null); len=$((len / 1000000)); if [ \"$status\" = \"Playing\" ] || [ \"$status\" = \"Paused\" ]; then artist=$(playerctl --player=%any metadata artist 2>/dev/null); title=$(playerctl --player=%any metadata title 2>/dev/null); if [ -n \"$title\" ]; then text=\"$title\"; [ -n \"$artist\" ] && text=\"$title <br>$artist\"; if [ ${#text} -gt 43 ]; then text=\"${text:0:43}...\"; fi; echo \"$status|$text|$pos|$len\"; else echo 'stopped||0|0'; fi; else echo 'stopped||0|0'; fi"]
    command: ["bash", "-c", "status=$(playerctl --player=%any status 2>/dev/null); pos=$(playerctl --player=%any position 2>/dev/null | cut -d. -f1); len=$(playerctl --player=%any metadata mpris:length 2>/dev/null); len=$((len / 1000000)); if [ \"$status\" = \"Playing\" ] || [ \"$status\" = \"Paused\" ]; then artist=$(playerctl --player=%any metadata artist 2>/dev/null); title=$(playerctl --player=%any metadata title 2>/dev/null); if [ -n \"$title\" ]; then [ ${#title} -gt 90 ] && title=\"${title:0:90}...\"; text=\"$title<br>$artist\"; echo \"$status|$text|$pos|$len\"; else echo 'stopped||0|0'; fi; else echo 'stopped||0|0'; fi"]
    stdout: SplitParser {
        onRead: data => {
          var parts = data.trim().split("|")
          if (parts.length >= 4) {
            synth.mediaClass = parts[0].toLowerCase()
            synth.mediaText = parts[1].replace("<br>" , "\n")
            synth.mediaPosition = parseInt(parts[2]) || 0
            synth.mediaLength = parseInt(parts[3]) || 0
          }
        }
    }
  }

  Process {
    id: cavaProc
    running: synth.visible
    command: ["cava", "-p", Quickshell.env("HOME") + "/.config/cava/config_raw_synth"]
    stdout: SplitParser {
      onRead: data => {
        var parts = data.trim().split(";")
        var vals = []
        for (var i = 0; i < 48 && i < parts.length; i++) {
            var parsed = parseInt(parts[i])
            vals.push(isNaN(parsed) ? 0.1 : (parsed / 255))
        }
        while (vals.length < 48) vals.push(0.1)
        if (vals.length > 0) {
          synth.cavaValues = vals
        }
      }
    }
  }

  Process {
    id: mediaPlayPauseProc
    command: ["playerctl", "play-pause"]
    onExited: { if (!mediaProc.running) mediaProc.running = true }
  }

  Process {
    id: mediaNextProc
    command: ["playerctl", "next"]
    onExited: { if (!mediaProc.running) mediaProc.running = true }
  }

  Process {
    id: mediaPrevProc
    command: ["playerctl", "previous"]
    onExited: { if (!mediaProc.running) mediaProc.running = true }
  }


  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(root.walBackground.r, root.walBackground.g, root.walBackground.b, 0.7)
    radius: 5

    Text {
      id: mediaLabel
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.margins: 16
      text: synth.mediaText
      color: root.walColor5
      font.pixelSize: 11
      font.bold: true
      font.family: "JetBrainsMono Nerd Font"
      opacity: synth.mediaClass === "playing" ? 0.6 : 0.4
      Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    }

    Row {
      anchors.top: parent.top
      anchors.right: parent.right
      anchors.rightMargin: 16
      anchors.topMargin: 14
      spacing: 26

      MediaBtn {
        icon: "󰒮"
        iconSize: 15
        onClicked: { if (!mediaPrevProc.running) mediaPrevProc.running = true }
      }

      MediaBtn {
        icon: synth.mediaClass === "playing" ? "󰏤" : "󰐊" 
        iconSize: 15
        onClicked: { if (!mediaPlayPauseProc.running) mediaPlayPauseProc.running = true }
      }

      MediaBtn {
        icon: "󰒭"
        iconSize: 15
        onClicked: { if (!mediaNextProc.running) mediaNextProc.running = true }
      }
    }

    Row {
      anchors.fill: parent
      anchors.margins: 16
      spacing: 2

      Repeater {
        model: 48

        Rectangle {
          width: (parent.width - (parent.spacing * (synth.cavaValues.length - 1))) / Math.max(1, synth.cavaValues.length)
          height: Math.max(5, synth.cavaValues[index] * parent.height)
          anchors.bottom: parent.bottom
          radius: 3
          color: root.walColor1
          antialiasing: true
          Behavior on height {
            NumberAnimation { duration: 50; easing.type: Easing.OutQuad }
          }
        }
      }
    }
  }
}
