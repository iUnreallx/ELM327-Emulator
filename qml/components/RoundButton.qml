import QtQuick

/// Круглая иконка-кнопка (36px)
Rectangle {
    id: root

    property string iconName: ""
    property color iconColor: Theme.label
    property color fillColor: mouse.containsMouse ? Theme.fill2 : Theme.fill
    property real diameter: 36
    signal clicked()

    width: diameter
    height: diameter
    radius: diameter / 2
    color: fillColor
    Behavior on color { ColorAnimation { duration: 150 } }
    scale: mouse.pressed ? 0.88 : 1
    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }

    Icon { anchors.centerIn: parent; name: root.iconName; size: root.diameter * 0.5; color: root.iconColor }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
