import QtQuick
import QtQuick.Layouts

/// Бейдж: tone = "gray" | "green" | "red" | "acc"
Rectangle {
    id: root

    property string text: ""
    property string tone: "gray"
    property bool mono: false

    readonly property color toneColor: tone === "green" ? Theme.green
                                     : tone === "red" ? Theme.red
                                     : tone === "acc" ? Theme.accent
                                     : Theme.label2

    implicitWidth: label.implicitWidth + 20
    implicitHeight: 24
    radius: 12
    color: tone === "gray" ? Theme.fill : Theme.tint(toneColor, 0.16)

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.toneColor
        font.family: root.mono ? Theme.monoFamily : Theme.fontFamily
        font.pixelSize: 12
        font.weight: Font.DemiBold
    }
}
