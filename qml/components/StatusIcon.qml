import QtQuick

/// Плитка статуса сервера: серая, когда выключен; зелёная с «пингом», когда включён
Rectangle {
    id: root

    property bool on: false
    property real tile: 60
    property string iconName: "plug"

    implicitWidth: tile
    implicitHeight: tile
    radius: tile / 3
    color: on ? Theme.tint(Theme.green, 0.18) : Theme.fill
    Behavior on color { ColorAnimation { duration: 400 } }

    Rectangle {
        id: ping
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: 2
        border.color: Theme.green
        visible: root.on
        opacity: 0

        ParallelAnimation {
            running: root.on && root.visible
            loops: Animation.Infinite
            NumberAnimation { target: ping; property: "scale"; from: 1; to: 1.4; duration: 2200; easing.type: Easing.OutCubic }
            NumberAnimation { target: ping; property: "opacity"; from: 0.55; to: 0; duration: 2200 }
        }
    }

    Icon {
        anchors.centerIn: parent
        name: root.iconName
        size: root.tile * 0.5
        color: root.on ? Theme.green : Theme.label2
    }
}
