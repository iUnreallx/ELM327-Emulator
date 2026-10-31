import QtQuick

/// Чип сценария / профиля: иконка + название, активный заливается акцентом
Rectangle {
    id: root

    property string text: ""
    property string iconName: ""
    property bool active: false
    signal clicked()

    implicitHeight: 42
    implicitWidth: row.width + 30
    radius: 21
    color: active ? Theme.accent : Theme.surface
    border.width: active ? 0 : 1
    border.color: Theme.hairline
    y: mouse.containsMouse && !mouse.pressed ? -2 : 0
    scale: mouse.pressed ? 0.94 : 1
    Behavior on color { ColorAnimation { duration: 250 } }
    Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }
    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }

    Row {
        id: row
        x: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            size: 19
            color: root.active ? Theme.accentFg : Theme.label
            scale: mouse.containsMouse ? 1.2 : 1
            rotation: mouse.containsMouse ? -8 : 0
            Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }
            Behavior on rotation { NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: root.active ? Theme.accentFg : Theme.label
            font.family: Theme.fontFamily
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
