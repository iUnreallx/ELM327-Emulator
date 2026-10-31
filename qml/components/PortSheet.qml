import QtQuick
import QtQuick.Layouts

/// Нижняя панель выбора COM-порта
Rectangle {
    id: root

    required property var app
    property bool shown: false
    signal closeRequested()

    width: Math.min(440, parent ? parent.width : 440)
    height: col.implicitHeight + 38
    radius: 28
    color: Theme.surface
    x: parent ? (parent.width - width) / 2 : 0
    y: shown ? parent.height - height + radius : parent.height + 20
    Behavior on y { NumberAnimation { duration: 550; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }

    ColumnLayout {
        id: col
        x: 22
        y: 10
        width: parent.width - 44
        spacing: 0

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 38
            Layout.preferredHeight: 5
            radius: 3
            color: Theme.fill2
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 14
            text: qsTr("COM port")
            color: Theme.label
            font.family: Theme.fontFamily
            font.pixelSize: 18
            font.weight: Font.Bold
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.app.ports.length > 0 ? qsTr("Choose the port your app is connected to") : qsTr("No COM ports found")
            color: Theme.label2
            font.family: Theme.fontFamily
            font.pixelSize: 14
        }

        Group {
            Layout.fillWidth: true
            Layout.topMargin: 16
            visible: root.app.ports.length > 0

            Repeater {
                model: root.app.ports
                delegate: Cell {
                    first: index === 0
                    tappable: true
                    title: modelData
                    onClicked: {
                        root.app.com = modelData
                        root.closeRequested()
                    }
                    Icon {
                        visible: root.app.com === modelData
                        name: "check"
                        size: 18
                        color: Theme.accent
                    }
                }
            }
        }

        AppButton {
            Layout.fillWidth: true
            Layout.topMargin: 18
            size: "lg"
            text: root.app.ports.length > 0 ? qsTr("Cancel") : qsTr("Close")
            onClicked: root.closeRequested()
        }
    }
}
