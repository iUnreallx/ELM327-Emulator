import QtQuick

/// Плитка параметра как в Пункте управления: тянешь вверх/вниз — значение растёт.
/// Клик по числу — ввод, колесо мыши — шаг.
Rectangle {
    id: root

    property var app
    property string key: "speed"
    readonly property var def: ParamDefs.defs[key]
    readonly property real current: app.value(key)
    readonly property bool warn: current >= def.warn
    readonly property color tone: warn ? Theme.red : Theme[def.tone]
    property int pop: -1

    property real shown: app.fraction(key)
    Behavior on shown { enabled: !area.pressed; NumberAnimation { duration: 900; easing.type: Easing.OutBack; easing.overshoot: 0.9 } }

    implicitHeight: 330
    radius: 30
    color: Theme.surface
    border.width: 1
    border.color: Theme.hairline
    transform: [
        Translate { id: pt },
        Translate { y: area.containsMouse ? -3 : 0; Behavior on y { NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.6 } } }
    ]

    onVisibleChanged: if (visible && pop >= 0) popAnim.restart()
    Component.onCompleted: if (visible && pop >= 0) popAnim.restart()
    SequentialAnimation {
        id: popAnim
        PropertyAction { target: root; property: "opacity"; value: 0 }
        PauseAnimation { duration: Math.max(0, root.pop) * 60 }
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; from: 0; to: 1; duration: 450 }
            NumberAnimation { target: pt; property: "y"; from: 18; to: 0; duration: 700; easing.type: Easing.OutBack; easing.overshoot: 1.3 }
        }
    }

    // заливка: обрезаем нижнюю часть скруглённого прямоугольника
    Item {
        id: fill
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.height * root.shown
        clip: true
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: root.height
            radius: root.radius
            color: root.tone
            opacity: 0.95
            Behavior on color { ColorAnimation { duration: 300 } }
        }
    }

    Rectangle { // ручка
        x: (root.width - width) / 2
        y: root.height - fill.height - 3
        width: 38
        height: 5
        radius: 3
        color: "#bfffffff"
        visible: fill.height > 8
    }

    Column { // шкала
        x: root.width - 16
        y: 66
        spacing: (root.height - 132 - 9) / 8
        opacity: 0.6
        Repeater { model: 9; delegate: Rectangle { width: 6; height: 1; color: Theme.label3 } }
    }

    Column {
        x: 16
        y: 16
        z: 2
        Text {
            text: root.def.title
            color: Theme.label2
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }
        Odo {
            pixelSize: 34
            value: root.current
            decimals: root.def.dec
            clickable: true
            onClicked: root.app.editRequested(root.key)
        }
        Text {
            text: root.def.unit
            color: Theme.label2
            font.family: Theme.fontFamily
            font.pixelSize: 13
            font.weight: Font.Medium
        }
    }

    Row {
        x: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        width: parent.width - 32
        Rectangle {
            width: 34; height: 34; radius: 10
            color: "#40000000"
            Icon { anchors.centerIn: parent; name: root.def.icon; size: 17; color: "white" }
        }
        Item { width: parent.width - 34 - pid.width; height: 1 }
        Rectangle {
            id: pid
            anchors.bottom: parent.bottom
            width: pidT.implicitWidth + 16
            height: 22
            radius: 8
            color: "#47000000"
            Text { id: pidT; anchors.centerIn: parent; text: root.def.pid; color: "white"; font.family: Theme.monoFamily; font.pixelSize: 11 }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.SizeVerCursor
        preventStealing: true
        property real v0: 0
        property real y0: 0
        onPressed: function (m) { v0 = root.app.value(root.key); y0 = m.y }
        onPositionChanged: function (m) {
            if (!pressed) return
            var d = root.def
            root.app.setValue(root.key, v0 - (m.y - y0) / root.height * (d.to - d.from))
        }
        onWheel: function (w) {
            var d = root.def
            root.app.setValue(root.key, root.app.value(root.key) + (w.angleDelta.y > 0 ? 1 : -1) * d.step * (d.to > 1000 ? 5 : (d.to > 100 ? 3 : 1)))
        }
    }
}
