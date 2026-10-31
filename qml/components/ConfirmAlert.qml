import QtQuick
import QtQuick.Layouts

/// Окно подтверждения как в iOS
Rectangle {
    id: root

    property bool shown: false
    property string title: ""
    property string message: ""
    property string okText: "OK"
    property bool destructive: true
    property var callback: null
    signal closeRequested()

    width: 320
    height: body.y + body.implicitHeight + 49
    radius: 20
    color: Theme.surface
    anchors.centerIn: parent
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.94
    visible: opacity > 0.01
    Behavior on opacity { NumberAnimation { duration: 180 } }
    Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    Column {
        id: body
        x: 24
        y: 24
        width: parent.width - 48
        spacing: 8

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: root.title
            color: Theme.label
            font.family: Theme.fontFamily
            font.pixelSize: 17
            font.weight: Font.Bold
            wrapMode: Text.WordWrap
        }
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: root.message
            color: Theme.label2
            font.family: Theme.fontFamily
            font.pixelSize: 14
            lineHeight: 1.2
            wrapMode: Text.WordWrap
        }
        Item { width: 1; height: 12 }
    }

    Rectangle { x: 0; y: root.height - 49; width: root.width; height: 1; color: Theme.separator }
    Rectangle { x: root.width / 2; y: root.height - 48; width: 1; height: 48; color: Theme.separator }

    Row {
        y: root.height - 48
        Repeater {
            model: [qsTr("Cancel"), root.okText]
            delegate: Rectangle {
                width: root.width / 2
                height: 48
                color: area.pressed ? Theme.fill2 : (area.containsMouse ? Theme.fill : "transparent")
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: index === 1 && root.destructive ? Theme.red : Theme.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: 16
                    font.weight: index === 1 ? Font.DemiBold : Font.Normal
                }
                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var cb = root.callback
                        root.closeRequested()
                        if (index === 1 && cb) cb()
                    }
                }
            }
        }
    }
}
