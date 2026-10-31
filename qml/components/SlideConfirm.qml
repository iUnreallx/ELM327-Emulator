import QtQuick

/// «Slide to confirm»: тянешь ручку до конца — действие подтверждено
Rectangle {
    id: root

    property string text: ""
    property string iconName: "power"
    property color tone: Theme.green
    signal confirmed()

    readonly property real maxX: width - knob.width - 8
    property bool done: false

    implicitHeight: 60
    radius: 30
    color: Theme.fill
    clip: true

    Timer { id: resetT; interval: 1800; onTriggered: root.reset() }

    function reset() { done = false; knob.x = 4 }
    onToneChanged: reset()

    Rectangle { // след
        height: parent.height
        width: knob.x + knob.width + 4
        radius: parent.radius
        color: Theme.tint(root.tone, 0.30)
    }

    Text {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 22
        text: root.text
        color: Theme.label
        opacity: Math.max(0, 1 - (knob.x - 4) / Math.max(1, root.maxX) * 1.4) * 0.8
        font.family: Theme.fontFamily
        font.pixelSize: 15
        font.weight: Font.DemiBold
    }

    Rectangle {
        id: knob
        x: 4
        y: 4
        width: 52
        height: 52
        radius: 26
        color: root.tone
        Behavior on x { enabled: !drag.pressed; NumberAnimation { duration: 550; easing.type: Easing.OutBack; easing.overshoot: 1.4 } }
        Behavior on color { ColorAnimation { duration: 300 } }

        Rectangle { // свечение
            z: -1
            anchors.fill: parent
            anchors.topMargin: 6
            anchors.bottomMargin: -4
            radius: width / 2
            color: Theme.tint(root.tone, 0.45)
        }
        Icon { anchors.centerIn: parent; name: root.iconName; size: 22; color: "white" }

        MouseArea {
            id: drag
            anchors.fill: parent
            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            drag.target: knob
            drag.axis: Drag.XAxis
            drag.minimumX: 4
            drag.maximumX: root.maxX + 4
            onReleased: {
                if (root.done) return
                if (knob.x > root.maxX * 0.86) {
                    root.done = true
                    knob.x = root.maxX + 4
                    root.confirmed()
                    resetT.restart()
                } else {
                    knob.x = 4
                }
            }
        }
    }
}
