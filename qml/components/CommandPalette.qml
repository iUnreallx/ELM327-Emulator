import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/// Палитра команд (Ctrl+F): поиск по действиям, переходам, сценариям, профилям; понимает «speed 120».
Rectangle {
    id: root

    required property var app
    /// [{ group, title, icon, tone, kbd, run }]
    property var commands: []
    property bool shown: false
    signal closeRequested()

    property int sel: 0
    property var items: []
    property var pending: null

    width: Math.min(620, (parent ? parent.width : 700) - 24)
    height: col.implicitHeight
    x: parent ? (parent.width - width) / 2 : 0
    y: (parent ? parent.height : 600) * 0.14
    radius: 20
    color: Theme.dark ? Qt.rgba(36 / 255, 36 / 255, 38 / 255, 0.98) : Qt.rgba(1, 1, 1, 0.98)
    border.width: 1
    border.color: Theme.separator

    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.96
    visible: opacity > 0.01
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.4 } }

    function toneOf(t) {
        if (t === "acc") return Theme.accent
        if (t && t.charAt(0) === "#") return t
        return Theme[t] !== undefined ? Theme[t] : Theme.gray
    }

    function refresh() {
        var q = input.text.trim().toLowerCase()
        var m = q.match(/^(speed|rpm|temp|volt|load|thr)\s+(-?\d+(?:[.,]\d+)?)$/)
        var out = []
        if (m) {
            var k = m[1], v = parseFloat(m[2].replace(",", ".")), d = ParamDefs.defs[k]
            out.push({ group: qsTr("Set value"), title: qsTr("Set %1 to %2 %3").arg(d.title).arg(v).arg(d.unit), icon: d.icon, tone: d.tone,
                       run: function () { root.app.setValue(k, v); root.app.island(qsTr("%1 set").arg(d.title), root.app.format(k) + " " + d.unit, "acc", d.icon) } })
        } else {
            for (var i = 0; i < commands.length; ++i) {
                var c = commands[i]
                if (q === "" || c.title.toLowerCase().indexOf(q) >= 0 || c.group.toLowerCase().indexOf(q) >= 0) out.push(c)
            }
        }
        items = out
        sel = Math.max(0, Math.min(sel, out.length - 1))
    }

    onShownChanged: {
        if (shown) { input.text = ""; sel = 0; refresh(); input.forceActiveFocus() }
    }

    function run(i) {
        var c = items[i]
        if (!c) return
        pending = c.run
        closeRequested()
        fire.restart()
    }
    Timer { id: fire; interval: 130; onTriggered: if (root.pending) { var f = root.pending; root.pending = null; f() } }

    MouseArea { anchors.fill: parent } // не пропускаем клики сквозь окно

    ColumnLayout {
        id: col
        width: parent.width
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            spacing: 10
            Icon { name: "search"; size: 20; color: Theme.label2 }
            TextInput {
                id: input
                Layout.fillWidth: true
                color: Theme.label
                font.family: Theme.fontFamily
                font.pixelSize: 18
                selectionColor: Theme.accent
                selectByMouse: true
                clip: true
                onTextChanged: { root.sel = 0; root.refresh() }
                Keys.onPressed: function (e) {
                    if (e.key === Qt.Key_Down) { root.sel = (root.sel + 1) % Math.max(1, root.items.length); list.positionViewAtIndex(root.sel, ListView.Contain); e.accepted = true }
                    else if (e.key === Qt.Key_Up) { root.sel = (root.sel - 1 + root.items.length) % Math.max(1, root.items.length); list.positionViewAtIndex(root.sel, ListView.Contain); e.accepted = true }
                    else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { root.run(root.sel); e.accepted = true }
                    else if (e.key === Qt.Key_Escape) { root.closeRequested(); e.accepted = true }
                }
                Text {
                    visible: input.text === ""
                    text: qsTr("Type a command, or: speed 120, rpm 3000…")
                    color: Theme.label3
                    font: input.font
                }
            }
            Rectangle {
                Layout.preferredWidth: escT.implicitWidth + 14
                Layout.preferredHeight: 22
                radius: 6
                color: Theme.fill
                Text { id: escT; anchors.centerIn: parent; text: "Esc"; color: Theme.label2; font.family: Theme.monoFamily; font.pixelSize: 11 }
            }
        }
        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.separator; opacity: 0.7 }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(360, Math.max(60, contentHeight + 16))
            Layout.margins: 0
            topMargin: 8
            bottomMargin: 8
            leftMargin: 8
            rightMargin: 8
            clip: true
            model: root.items
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ThemedScrollBar {}

            delegate: Item {
                id: it
                readonly property bool header: index === 0 || root.items[index - 1].group !== modelData.group
                width: list.width - 16
                height: (header ? 30 : 0) + 46

                Text {
                    visible: it.header
                    x: 10
                    y: 10
                    text: modelData.group
                    color: Theme.label2
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }
                Rectangle {
                    y: it.header ? 30 : 0
                    width: parent.width
                    height: 46
                    radius: 12
                    color: root.sel === index ? Theme.fill2 : "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12
                        Rectangle {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            radius: 8
                            color: root.toneOf(modelData.tone)
                            Icon { anchors.centerIn: parent; name: modelData.icon; size: 16; color: modelData.tone === "acc" ? Theme.accentFg : "white" }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: modelData.title
                            color: Theme.label
                            font.family: Theme.fontFamily
                            font.pixelSize: 15
                            elide: Text.ElideRight
                        }
                        Rectangle {
                            visible: !!modelData.kbd
                            Layout.preferredWidth: kT.implicitWidth + 14
                            Layout.preferredHeight: 22
                            radius: 6
                            color: Theme.fill
                            Text { id: kT; anchors.centerIn: parent; text: modelData.kbd || ""; color: Theme.label2; font.family: Theme.monoFamily; font.pixelSize: 11 }
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.sel = index
                        onClicked: root.run(index)
                    }
                }
            }

            Text {
                visible: root.items.length === 0
                anchors.centerIn: parent
                text: qsTr("Nothing found. Try “speed 120”.")
                color: Theme.label2
                font.family: Theme.fontFamily
                font.pixelSize: 15
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.separator; opacity: 0.7 }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            spacing: 14
            Repeater {
                model: [["↑↓", qsTr("select")], ["↵", qsTr("run")]]
                delegate: Row {
                    spacing: 6
                    Rectangle {
                        width: kk.implicitWidth + 14; height: 20; radius: 6; color: Theme.fill
                        Text { id: kk; anchors.centerIn: parent; text: modelData[0]; color: Theme.label2; font.family: Theme.monoFamily; font.pixelSize: 11 }
                    }
                    Text { anchors.verticalCenter: parent.verticalCenter; text: modelData[1]; color: Theme.label2; font.family: Theme.fontFamily; font.pixelSize: 12 }
                }
            }
            Item { Layout.fillWidth: true }
            Text { text: "Elm327 Emulator"; color: Theme.label2; font.family: Theme.fontFamily; font.pixelSize: 12 }
        }
    }
}
