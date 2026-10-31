import QtQuick

/// Степпер «− | +». Удержание — значение бежит (как в iOS).
Rectangle {
    id: root

    signal step(int direction)

    implicitWidth: 91
    implicitHeight: 34
    radius: 10
    color: Theme.fill
    clip: true

    property int holdDir: 0

    Timer { id: delay; interval: 380; onTriggered: repeat.start() }
    Timer { id: repeat; interval: 70; repeat: true; onTriggered: root.step(root.holdDir) }

    function press(dir) {
        holdDir = dir
        step(dir)
        delay.restart()
    }
    function release() {
        delay.stop()
        repeat.stop()
    }

    Row {
        anchors.fill: parent

        Rectangle {
            width: 45
            height: parent.height
            color: minusArea.pressed ? Theme.fill2 : "transparent"
            Icon { anchors.centerIn: parent; name: "minus"; size: 16; color: Theme.label }
            MouseArea {
                id: minusArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: root.press(-1)
                onReleased: root.release()
                onCanceled: root.release()
            }
        }

        Rectangle { width: 1; height: 18; anchors.verticalCenter: parent.verticalCenter; color: Theme.separator }

        Rectangle {
            width: 45
            height: parent.height
            color: plusArea.pressed ? Theme.fill2 : "transparent"
            Icon { anchors.centerIn: parent; name: "plus"; size: 16; color: Theme.label }
            MouseArea {
                id: plusArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: root.press(1)
                onReleased: root.release()
                onCanceled: root.release()
            }
        }
    }
}
