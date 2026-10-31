import QtQuick

/// Стопка тостов справа внизу: новые приходят снизу пружиной, старые уходят «вглубь»,
/// при наведении стопка раскрывается. Смахивание вправо закрывает, «Undo» откатывает действие.
Item {
    id: root

    width: 360
    height: 400

    property int seq: 0
    property var undos: ({})
    readonly property bool hovered: hover.hovered
    readonly property int cardH: 64

    function toneColor(k) {
        switch (k) {
        case "red": return Theme.red
        case "gray": return Theme.gray
        case "acc": return Theme.accent
        case "blue": return Theme.blue
        case "orange": return Theme.orange
        default: return Theme.green
        }
    }
    function toneFg(k) { return k === "acc" ? Theme.accentFg : "#ffffff" }

    function show(title, sub, kind, ic, undo) {
        var id = ++seq
        if (undo) { var u = undos; u[id] = undo; undos = u }
        var dur = undo ? 5600 : 3800
        tmodel.insert(0, { tid: id, title: title, sub: sub, tone: kind, ic: ic, hasUndo: !!undo, total: dur, left: dur, dying: false })
        if (tmodel.count > 6) kill(tmodel.get(tmodel.count - 1).tid)
    }

    function indexOfId(id) {
        for (var i = 0; i < tmodel.count; ++i) if (tmodel.get(i).tid === id) return i
        return -1
    }
    function kill(id) {
        var i = indexOfId(id)
        if (i < 0 || tmodel.get(i).dying) return
        tmodel.setProperty(i, "dying", true)
        Qt.callLater(function () { reaper.ids.push(id); reaper.restart() })
    }
    Timer {
        id: reaper
        property var ids: []
        interval: 380
        onTriggered: {
            ids.forEach(function (id) { var i = root.indexOfId(id); if (i >= 0) tmodel.remove(i) })
            ids = []
        }
    }
    ListModel { id: tmodel }

    Timer {
        interval: 100
        repeat: true
        running: tmodel.count > 0 && !root.hovered
        onTriggered: {
            for (var i = tmodel.count - 1; i >= 0; --i) {
                var it = tmodel.get(i)
                if (it.dying) continue
                var left = it.left - 100
                tmodel.setProperty(i, "left", left)
                if (left <= 0) root.kill(it.tid)
            }
        }
    }

    HoverHandler { id: hover }

    Repeater {
        model: tmodel
        delegate: Rectangle {
            id: card
            readonly property int pos: index
            property real dx: 0
            width: root.width
            height: root.cardH
            radius: 18
            color: Theme.surface
            border.width: 1
            border.color: Theme.separator
            anchors.right: parent.right
            y: root.height - height - (root.hovered ? pos * (root.cardH + 10) : pos * 12) + (born ? 0 : 80) + (model.dying ? 20 : 0)
            x: dx
            scale: (born ? 1 : 0.9) * (root.hovered ? 1 : 1 - pos * 0.05) * (model.dying ? 0.9 : 1)
            opacity: model.dying ? 0 : (born ? (root.hovered ? 1 : (pos > 2 ? 0 : 1)) : 0) * (1 - Math.max(0, dx) / 300)
            z: 100 - pos
            transformOrigin: Item.Bottom
            property bool born: false
            Component.onCompleted: born = true

            Behavior on y { NumberAnimation { duration: 550; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
            Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
            Behavior on opacity { NumberAnimation { duration: 280 } }
            Behavior on x { enabled: !drag.active; NumberAnimation { duration: 450; easing.type: Easing.OutBack } }

            Rectangle { // тень
                z: -1
                anchors.fill: parent
                anchors.topMargin: 8
                anchors.bottomMargin: -8
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                radius: parent.radius
                color: Theme.dark ? "#66000000" : "#26000000"
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 12

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32
                    height: 32
                    radius: 16
                    color: root.toneColor(model.tone)
                    Icon { anchors.centerIn: parent; name: model.ic; size: 16; color: root.toneFg(model.tone) }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 32 - 12 - (model.hasUndo ? undoBtn.width + 12 : 0)
                    Text {
                        width: parent.width
                        text: model.title
                        color: Theme.label
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        visible: model.sub !== ""
                        text: model.sub
                        color: Theme.label2
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                        elide: Text.ElideRight
                    }
                }
                Rectangle {
                    id: undoBtn
                    visible: model.hasUndo
                    anchors.verticalCenter: parent.verticalCenter
                    width: undoText.implicitWidth + 24
                    height: 30
                    radius: 15
                    color: Theme.tint(Theme.accentTint, undoMouse.containsMouse ? 0.26 : 0.16)
                    Text {
                        id: undoText
                        anchors.centerIn: parent
                        text: qsTr("Undo")
                        color: Theme.accentTint
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                    MouseArea {
                        id: undoMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var f = root.undos[model.tid]
                            root.kill(model.tid)
                            if (f) f()
                        }
                    }
                }
            }

            // полоска таймера
            Rectangle {
                x: 16
                y: parent.height - 4
                height: 2
                radius: 1
                width: (parent.width - 32) * Math.max(0, model.left / model.total)
                color: Theme.accent
                opacity: 0.8
            }

            DragHandler {
                id: drag
                target: null
                yAxis.enabled: false
                onTranslationChanged: if (active) card.dx = Math.max(translation.x * 0.3, translation.x)
                onActiveChanged: {
                    if (!active) {
                        if (card.dx > 110) root.kill(model.tid)
                        else card.dx = 0
                    }
                }
            }
        }
    }
}
