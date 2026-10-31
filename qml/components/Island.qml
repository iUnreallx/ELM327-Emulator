import QtQuick
import QtQuick.Layouts

/// Dynamic Island: в покое показывает статус сервера, раскрывается для уведомлений.
Item {
    id: root

    property bool connected: false
    property bool open: false
    property real maxWidth: 420

    property string title: ""
    property string desc: ""
    property string kind: "green"     // green | gray | red | acc
    property string iconName: "check"

    signal toggleRequested()
    signal statusRequested()

    width: body.width
    height: body.height

    function show(t, d, k, i) {
        title = t
        desc = d
        kind = k
        iconName = i
        open = true
        closeTimer.restart()
    }

    function pulse() { pulseAnim.restart() }

    Timer { id: closeTimer; interval: 2800; onTriggered: root.open = false }

    Rectangle {
        id: body
        width: root.open ? Math.min(root.maxWidth, (root.parent ? root.parent.width : 600) - 24) : 136
        height: root.open ? 76 : 44
        radius: height / 2
        color: "#000000"
        border.width: 1
        border.color: "#14ffffff"
        clip: true

        Behavior on width { NumberAnimation { duration: 550; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
        Behavior on height { NumberAnimation { duration: 550; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }

        // покой: «камера» слева, статус справа
        Item {
            anchors.fill: parent
            opacity: root.open ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Rectangle {
                x: 16
                anchors.verticalCenter: parent.verticalCenter
                width: 11
                height: 11
                radius: 6
                color: "#0a0a12"
                border.width: 1.5
                border.color: "#151522"
            }
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
                Rectangle {
                    id: liveDot
                    anchors.verticalCenter: parent.verticalCenter
                    width: 7
                    height: 7
                    radius: 4
                    color: root.connected ? "#30d158" : "#8e8e93"
                    SequentialAnimation {
                        id: pulseAnim
                        NumberAnimation { target: liveDot; property: "scale"; to: 1.7; duration: 90 }
                        NumberAnimation { target: liveDot; property: "scale"; to: 1; duration: 160 }
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.connected ? qsTr("Live") : qsTr("Offline")
                    color: root.connected ? "#30d158" : "#8e8e93"
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }
                Row { // эквалайзер: живёт, пока идёт сессия
                    anchors.verticalCenter: parent.verticalCenter
                    height: 12
                    spacing: 2
                    Repeater {
                        model: 3
                        delegate: Rectangle {
                            id: bar
                            anchors.bottom: parent.bottom
                            width: 3
                            height: 3
                            radius: 1.5
                            color: root.connected ? "#30d158" : "#8e8e93"
                            SequentialAnimation {
                                running: root.connected
                                loops: Animation.Infinite
                                PauseAnimation { duration: index * 200 }
                                NumberAnimation { target: bar; property: "height"; to: 12; duration: 450; easing.type: Easing.InOutSine }
                                NumberAnimation { target: bar; property: "height"; to: 3; duration: 450; easing.type: Easing.InOutSine }
                            }
                        }
                    }
                }
            }
        }

        // раскрытое состояние
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12
            opacity: root.open ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 16
                color: root.kind === "green" ? "#30d158"
                     : root.kind === "red" ? "#ff453a"
                     : root.kind === "acc" ? Theme.accent
                     : "#3a3a3c"
                Icon {
                    anchors.centerIn: parent
                    name: root.iconName
                    size: 24
                    color: root.kind === "green" ? "#000000" : (root.kind === "acc" ? Theme.accentFg : "#ffffff")
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Text {
                    Layout.fillWidth: true
                    text: root.title
                    color: "white"
                    font.family: Theme.fontFamily
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: root.desc
                    color: "#99ebebf5"
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    elide: Text.ElideRight
                }
            }
            RoundButton {
                diameter: 40
                iconName: root.connected ? "stop" : "play"
                iconColor: "white"
                fillColor: "#24ffffff"
                onClicked: root.toggleRequested()
            }
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.open) {
                    closeTimer.stop()
                    root.open = false
                } else {
                    root.statusRequested()
                }
            }
        }
    }
}
