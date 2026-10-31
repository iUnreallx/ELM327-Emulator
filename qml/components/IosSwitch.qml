import QtQuick

/// Переключатель как в iOS (пружинная ручка)
Rectangle {
    id: root

    property bool checked: false
    property bool small: false
    signal toggled(bool checked)

    readonly property int pad: 2
    readonly property int knobSize: height - pad * 2

    implicitWidth: small ? 42 : 51
    implicitHeight: small ? 26 : 31
    radius: height / 2
    color: checked ? Theme.accent : Theme.fill2
    Behavior on color { ColorAnimation { duration: 150 } }

    Rectangle { // тень ручки
        x: knob.x
        y: knob.y + 2
        width: knob.width
        height: knob.height
        radius: height / 2
        color: "#33000000"
    }

    Rectangle {
        id: knob
        y: root.pad
        x: root.checked ? root.width - width - root.pad : root.pad
        width: mouse.pressed ? root.knobSize + 6 : root.knobSize
        height: root.knobSize
        radius: height / 2
        color: "white"
        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
        Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
