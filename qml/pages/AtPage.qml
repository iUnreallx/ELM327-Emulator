import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../components"

PageBase {
    id: root

    required property var app

    readonly property real contentW: Math.min(width - Theme.pagePadding * 2, 1320 - Theme.pagePadding * 2)
    readonly property bool wide: contentW > 1100

    property int tab: 0            // 0 = AT, 1 = PID
    property string group: "All"
    property string query: ""

    scrollY: flick.contentY

    readonly property var groups: {
        var src = tab === 0 ? ParamDefs.atCommands : ParamDefs.pidList
        var g = ["All"]
        src.forEach(function (r) { if (g.indexOf(r[0]) < 0) g.push(r[0]) })
        return g
    }

    readonly property var rows: {
        var src = tab === 0 ? ParamDefs.atCommands : ParamDefs.pidList
        var out = [], g = "", q = query.trim().toLowerCase()
        src.forEach(function (r) {
            if (group !== "All" && r[0] !== group) return
            if (q !== "" && (r[1] + " " + r[2]).toLowerCase().indexOf(q) < 0) return
            if (group === "All" && r[0] !== g) { g = r[0]; out.push({ header: true, text: g, code: "", desc: "", spec: "" }) }
            out.push({ header: false, text: "", code: r[1], desc: r[2], spec: r[3] })
        })
        return out
    }
    readonly property int shownCount: rows.filter(function (r) { return !r.header }).length
    readonly property int totalCount: (tab === 0 ? ParamDefs.atCommands : ParamDefs.pidList).length

    onTabChanged: group = "All"

    // ── терминал ──
    ListModel { id: term }
    Component {
        id: delayed
        Timer {
            property var payload
            running: true
            onTriggered: {
                term.append(payload)
                termList.positionViewAtEnd()
                destroy()
            }
        }
    }
    function send(raw) {
        var c = raw.replace(/\s+/g, "").toUpperCase()
        if (c === "") return
        var resp = root.app.answerFor(c)
        var isAt = c.indexOf("AT") === 0
        var base = isAt ? delayManager.atDelay : delayManager.obdDelay
        var ms = Math.max(5, Math.round(base + (Math.random() * 2 - 1) * delayManager.jitter))
        delayed.createObject(root, { interval: ms, payload: { cmd: c, resp: resp, ms: ms, bad: resp === "?" } })
    }

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight + 160
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ThemedScrollBar {}

        ColumnLayout {
            id: column
            x: (flick.width - width) / 2
            y: 20
            width: root.contentW
            spacing: Theme.gap

            PageHeader {
                Layout.topMargin: 14
                Layout.bottomMargin: 6
                scroll: flick.contentY
                title: qsTr("AT commands")
                subtitle: qsTr("Everything the adapter understands, and what clients send")
            }

            GridLayout {
                Layout.fillWidth: true
                columns: root.wide ? 2 : 1
                columnSpacing: Theme.gap
                rowSpacing: Theme.gap

                // ── справочник ──
                Panel {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.horizontalStretchFactor: 8
                    Layout.alignment: Qt.AlignTop
                    padding: 0
                    pop: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.margins: 20
                        Layout.topMargin: 18
                        Layout.bottomMargin: 10
                        spacing: 12

                        Segmented {
                            model: [qsTr("AT commands"), qsTr("OBD PIDs")]
                            currentIndex: root.tab
                            onPicked: function (i) { root.tab = i }
                        }
                        SearchField {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 120
                            Layout.maximumWidth: 240
                            placeholder: qsTr("Search command")
                            onTextChanged: root.query = text
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.shownCount + " " + qsTr("of") + " " + root.totalCount
                            color: Theme.label2
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                        }
                    }

                    Flow {
                        Layout.fillWidth: true
                        Layout.leftMargin: 20
                        Layout.rightMargin: 20
                        Layout.bottomMargin: 12
                        spacing: 8
                        Repeater {
                            model: root.groups
                            delegate: MiniChip {
                                text: modelData
                                active: root.group === modelData
                                onClicked: root.group = modelData
                            }
                        }
                    }

                    ListView {
                        id: cmdList
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(360, root.height - 380)
                        clip: true
                        model: root.rows
                        boundsBehavior: Flickable.StopAtBounds
                        ScrollBar.vertical: ThemedScrollBar {}

                        delegate: Item {
                            id: rowItem
                            readonly property bool isHeader: modelData.header
                            readonly property int uses: modelData.header ? 0 : (root.app.cmdUse[modelData.code] || 0)
                            width: cmdList.width
                            height: isHeader ? 40 : 46

                            Text {
                                visible: rowItem.isHeader
                                x: 22
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 6
                                text: modelData.text
                                color: Theme.label2
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                font.letterSpacing: 1
                                font.capitalization: Font.AllUppercase
                            }

                            Rectangle {
                                id: hl
                                visible: !rowItem.isHeader
                                anchors.fill: parent
                                color: rowMouse.containsMouse ? Theme.fill : "transparent"
                                Rectangle { // вспышка при получении команды
                                    id: flash
                                    anchors.fill: parent
                                    color: Theme.tint(Theme.accent, 0.30)
                                    opacity: 0
                                    NumberAnimation on opacity { id: flashAnim; running: false; from: 1; to: 0; duration: 1100; easing.type: Easing.OutCubic }
                                }
                                Rectangle { visible: index > 0 && !(root.rows[index - 1] && root.rows[index - 1].header); x: 22; width: parent.width - 22; height: 1; color: Theme.separator; opacity: 0.6 }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 22
                                    anchors.rightMargin: 22
                                    spacing: 14
                                    Text {
                                        Layout.preferredWidth: 90
                                        text: modelData.code
                                        color: Theme.accent
                                        font.family: Theme.monoFamily
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 0
                                        Layout.horizontalStretchFactor: 5
                                        text: modelData.desc
                                        color: Theme.label
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 15
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        Layout.preferredWidth: 0
                                        Layout.horizontalStretchFactor: 4
                                        text: root.app.commandText(modelData.spec)
                                        color: Theme.label2
                                        font.family: Theme.monoFamily
                                        font.pixelSize: 13
                                        elide: Text.ElideRight
                                    }
                                    Rectangle {
                                        Layout.preferredWidth: Math.max(26, cnt.implicitWidth + 14)
                                        Layout.preferredHeight: 22
                                        radius: 11
                                        color: rowItem.uses > 0 ? Theme.tint(Theme.accent, 0.18) : Theme.fill
                                        Text {
                                            id: cnt
                                            anchors.centerIn: parent
                                            text: rowItem.uses
                                            color: rowItem.uses > 0 ? Theme.accent : Theme.label3
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 12
                                            font.weight: Font.Bold
                                        }
                                    }
                                }
                                MouseArea {
                                    id: rowMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { termInput.text = modelData.code; termInput.forceActiveFocus() }
                                }
                            }
                            Connections {
                                target: root.app
                                function onCommandSeen(code) { if (!rowItem.isHeader && code === modelData.code) flashAnim.restart() }
                            }
                        }
                    }
                }

                // ── терминал ──
                Panel {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.horizontalStretchFactor: 4
                    Layout.alignment: Qt.AlignTop
                    Layout.minimumHeight: 520
                    pop: 1

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: qsTr("Try a command"); color: Theme.label; font.family: Theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold }
                        Text { text: qsTr("Answers use your delay settings"); color: Theme.label2; font.family: Theme.fontFamily; font.pixelSize: 14 }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.topMargin: 14
                        Layout.minimumHeight: 240
                        radius: 16
                        color: Theme.group
                        clip: true

                        Text {
                            visible: term.count === 0
                            anchors.centerIn: parent
                            width: parent.width - 40
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: qsTr("Click a command on the left or type your own.")
                            color: Theme.label3
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                        }

                        ListView {
                            id: termList
                            anchors.fill: parent
                            anchors.margins: 12
                            clip: true
                            model: term
                            spacing: 12
                            boundsBehavior: Flickable.StopAtBounds
                            delegate: Column {
                                width: termList.width
                                Text {
                                    text: "› " + model.cmd
                                    color: Theme.accent
                                    font.family: Theme.monoFamily
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                }
                                Item {
                                    width: parent.width
                                    height: ans.implicitHeight + 2
                                    Text {
                                        id: ans
                                        x: 16
                                        width: parent.width - 16 - msT.implicitWidth - 10
                                        text: model.resp
                                        wrapMode: Text.WrapAnywhere
                                        color: model.bad ? Theme.red : Theme.label
                                        font.family: Theme.monoFamily
                                        font.pixelSize: 14
                                    }
                                    Text {
                                        id: msT
                                        anchors.right: parent.right
                                        text: model.ms + " ms"
                                        color: Theme.label3
                                        font.family: Theme.monoFamily
                                        font.pixelSize: 11
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 12
                        Layout.preferredHeight: 46
                        radius: 14
                        color: Theme.fill
                        border.width: termInput.activeFocus ? 1.5 : 0
                        border.color: Theme.accent

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 6
                            spacing: 10
                            Text { text: "›"; color: Theme.label3; font.family: Theme.monoFamily; font.pixelSize: 15 }
                            TextInput {
                                id: termInput
                                Layout.fillWidth: true
                                color: Theme.label
                                font.family: Theme.monoFamily
                                font.pixelSize: 15
                                font.capitalization: Font.AllUppercase
                                selectionColor: Theme.accent
                                selectByMouse: true
                                clip: true
                                onAccepted: { root.send(text); text = "" }
                                Text {
                                    visible: termInput.text === ""
                                    text: qsTr("ATI, ATRV, 010C…")
                                    color: Theme.label3
                                    font.family: Theme.monoFamily
                                    font.pixelSize: 15
                                }
                            }
                            Rectangle {
                                Layout.preferredWidth: 34
                                Layout.preferredHeight: 34
                                radius: 17
                                color: Theme.accent
                                scale: sendMouse.pressed ? 0.88 : 1
                                Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }
                                Icon { anchors.centerIn: parent; name: "arrowUp"; size: 15; color: Theme.accentFg }
                                MouseArea {
                                    id: sendMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { root.send(termInput.text); termInput.text = "" }
                                }
                            }
                        }
                    }

                    Flow {
                        Layout.fillWidth: true
                        Layout.topMargin: 12
                        spacing: 8
                        Repeater {
                            model: ["ATZ", "ATI", "ATRV", "010C", "010D"]
                            delegate: MiniChip {
                                text: modelData
                                mono: true
                                onClicked: root.send(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
