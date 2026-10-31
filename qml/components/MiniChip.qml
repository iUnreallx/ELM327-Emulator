import QtQuick

/// Маленький фильтр-чип (30px)
Rectangle {
    id: root

    property string text: ""
    property bool active: false
    property bool mono: false
    signal clicked()

    implicitHeight: 30
    implicitWidth: label.implicitWidth + 26
    radius: 15
    color: active ? Theme.accent : (mouse.containsMouse ? Theme.fill2 : Theme.fill)
    scale: mouse.pressed ? 0.92 : 1
    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.active ? Theme.accentFg : (mouse.containsMouse ? Theme.label : Theme.label2)
        font.family: root.mono ? Theme.monoFamily : Theme.fontFamily
        font.pixelSize: 13
        font.weight: Font.DemiBold
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
