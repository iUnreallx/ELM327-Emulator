import QtQuick

/// Конфетти: fire() сыплет цветные кусочки сверху вниз (старт сервера)
Item {
    id: root

    signal fired()
    function fire() { fired() }

    readonly property var palette: ["#ff375f", "#ff9f0a", "#ffd60a", "#30d158", "#0a84ff", "#bf5af2"]

    enabled: false

    Repeater {
        model: 70
        delegate: Rectangle {
            id: piece
            property real t: 0
            readonly property real x0: Math.random() * root.width
            readonly property real drift: (Math.random() - 0.5) * 300
            readonly property real spin: Math.random() * 900
            readonly property int dur: 1600 + Math.random() * 1400
            readonly property int delay: Math.random() * 300

            width: 8
            height: 12
            radius: 2
            color: root.palette[index % root.palette.length]
            visible: t > 0 && t < 1
            x: x0 + drift * t
            y: -20 + t * (root.height + 80)
            rotation: spin * t

            SequentialAnimation {
                id: run
                PauseAnimation { duration: piece.delay }
                NumberAnimation { target: piece; property: "t"; from: 0.001; to: 1; duration: piece.dur; easing.type: Easing.OutQuad }
                ScriptAction { script: piece.t = 0 }
            }
            Connections { target: root; function onFired() { run.restart() } }
        }
    }
}
