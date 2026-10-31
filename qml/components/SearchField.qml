import QtQuick
import QtQuick.Controls.Basic

/// Поле поиска как в iOS
Rectangle {
    id: root

    property alias text: input.text
    property string placeholder: ""

    implicitWidth: 260
    implicitHeight: 36
    radius: Theme.rSm
    color: Theme.fill
    border.width: input.activeFocus ? 2 : 0
    border.color: Theme.tint(Theme.accent, 0.5)

    Icon { x: 12; anchors.verticalCenter: parent.verticalCenter; name: "search"; size: 16; color: Theme.label2 }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 38
        anchors.rightMargin: 12
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.label
        font.family: Theme.fontFamily
        font.pixelSize: 15
        selectionColor: Theme.accent
        clip: true
        selectByMouse: true

        Text {
            visible: input.text === ""
            anchors.verticalCenter: parent.verticalCenter
            text: root.placeholder
            color: Theme.label2
            font: input.font
        }
    }
}
