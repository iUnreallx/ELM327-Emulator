import QtQuick

/// Поле ввода с «плавающей» подписью: подпись уезжает вверх и уменьшается при фокусе/тексте
Rectangle {
    id: root

    property string label: ""
    property alias text: input.text
    property bool mono: true
    property int hints: Qt.ImhNone
    property bool locked: false
    signal edited(string text)

    readonly property bool lifted: input.activeFocus || input.text !== ""

    implicitHeight: 58
    radius: 14
    color: Theme.fill
    opacity: locked ? 0.5 : 1
    Behavior on opacity { NumberAnimation { duration: 250 } }

    Rectangle { // рамка фокуса
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: input.activeFocus ? 1.5 : 0
        border.color: Theme.accent
    }

    Text {
        id: lbl
        x: 14
        y: root.lifted ? 7 : 19
        text: root.label
        color: input.activeFocus ? Theme.accent : Theme.label2
        font.family: Theme.fontFamily
        font.pixelSize: 16
        scale: root.lifted ? 0.74 : 1
        transformOrigin: Item.TopLeft
        Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }
        Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    TextInput {
        id: input
        x: 14
        y: 26
        width: parent.width - 28
        enabled: !root.locked
        color: Theme.label
        font.family: root.mono ? Theme.monoFamily : Theme.fontFamily
        font.pixelSize: 17
        selectionColor: Theme.accent
        selectByMouse: true
        inputMethodHints: root.hints
        clip: true
        onTextEdited: root.edited(text)
    }

    MouseArea {
        anchors.fill: parent
        enabled: !root.locked
        cursorShape: Qt.IBeamCursor
        onPressed: function (e) { input.forceActiveFocus(); e.accepted = false }
    }
}
