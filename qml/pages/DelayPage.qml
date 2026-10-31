import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../components"

PageBase {
    id: root

    required property var app

    readonly property real contentW: Math.min(flick.width - Theme.pagePadding * 2, 1320 - Theme.pagePadding * 2)
    readonly property bool wide: contentW > 1100

    readonly property real atD: delayManager.atDelay
    readonly property real obdD: delayManager.obdDelay
    readonly property real jitD: delayManager.jitter

    scrollY: flick.contentY

    ListModel { id: hist }
    function sample() {
        var v = Math.max(1, Math.round(obdD + (Math.random() * 2 - 1) * jitD))
        hist.append({ v: v })
        if (hist.count > 30) hist.remove(0)
    }
    function reseed() {
        hist.clear()
        for (var i = 0; i < 30; ++i) sample()
    }
    onObdDChanged: reseed()
    onJitDChanged: reseed()
    Component.onCompleted: reseed()

    Timer { interval: 900; repeat: true; running: root.visible; onTriggered: root.sample() }

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
                title: qsTr("Response delay")
                subtitle: qsTr("Make the adapter fast, slow or unreliable")
            }

            // ── профили: компактная строка ──
            Flow {
                Layout.fillWidth: true
                spacing: 12
                Repeater {
                    model: ParamDefs.profileOrder
                    delegate: Rectangle {
                        id: prof
                        readonly property var p: ParamDefs.profiles[modelData]
                        readonly property bool active: (root.atD + root.obdD + root.jitD) >= 0 && root.app.presetActive(p)
                        width: pr.width + 32
                        height: 58
                        radius: 18
                        color: active ? Theme.accent : Theme.surface
                        border.width: active ? 0 : 1
                        border.color: Theme.hairline
                        y: pm.containsMouse && !pm.pressed ? -2 : 0
                        scale: pm.pressed ? 0.95 : 1
                        Behavior on color { ColorAnimation { duration: 250 } }
                        Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }
                        Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }

                        Row {
                            id: pr
                            x: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 34; height: 34; radius: 11
                                color: prof.active ? "#38ffffff" : Theme.fill
                                Icon {
                                    anchors.centerIn: parent
                                    name: ParamDefs.profileIcons[modelData]
                                    size: 18
                                    color: prof.active ? Theme.accentFg : Theme.label
                                    rotation: prof.active ? -6 : 0
                                    scale: prof.active ? 1.08 : 1
                                    Behavior on rotation { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }
                                    Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }
                                }
                            }
                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: modelData
                                    color: prof.active ? Theme.accentFg : Theme.label
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 15
                                    font.weight: Font.Bold
                                }
                                Text {
                                    text: prof.p.atDelay + " · " + prof.p.obdDelay + " · ±" + prof.p.jitter + " ms"
                                    color: prof.active ? Theme.accentFg : Theme.label2
                                    opacity: prof.active ? 0.8 : 1
                                    font.family: Theme.monoFamily
                                    font.pixelSize: 12
                                }
                            }
                        }
                        MouseArea {
                            id: pm
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.app.applyProfile(modelData)
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: root.wide ? 2 : 1
                columnSpacing: Theme.gap
                rowSpacing: Theme.gap

                // ── ползунки ──
                Panel {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.horizontalStretchFactor: 7
                    Layout.alignment: Qt.AlignTop
                    pop: 1

                    Repeater {
                        model: ["at", "obd", "jit"]
                        delegate: ColumnLayout {
                            id: dr
                            readonly property var def: ParamDefs.defs[modelData]
                            Layout.fillWidth: true
                            Layout.topMargin: index > 0 ? 26 : 0
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                ColumnLayout {
                                    spacing: 2
                                    Text { text: dr.def.title; color: Theme.label; font.family: Theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold }
                                    Text { text: dr.def.desc; color: Theme.label2; font.family: Theme.fontFamily; font.pixelSize: 14 }
                                }
                                Item { Layout.fillWidth: true }
                                Row {
                                    spacing: 6
                                    Odo { anchors.bottom: parent.bottom; pixelSize: 44; value: root.app.value(modelData) }
                                    Text { anchors.bottom: parent.bottom; anchors.bottomMargin: 8; text: "ms"; color: Theme.label2; font.family: Theme.fontFamily; font.pixelSize: 18 }
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                AppSlider {
                                    Layout.fillWidth: true
                                    from: dr.def.from
                                    to: dr.def.to
                                    stepSize: dr.def.step
                                    value: root.app.value(modelData)
                                    onMoved: root.app.setValue(modelData, value)
                                }
                                Stepper {
                                    onStep: function (dir) { root.app.setValue(modelData, root.app.value(modelData) + dir * dr.def.step * 5) }
                                }
                            }
                        }
                    }

                    // сброс удержанием
                    Rectangle {
                        id: hold
                        Layout.fillWidth: true
                        Layout.topMargin: 26
                        Layout.preferredHeight: 50
                        radius: Theme.rMd
                        color: Theme.fill
                        clip: true
                        property real progress: 0

                        Rectangle {
                            height: parent.height
                            width: parent.width * hold.progress
                            color: Theme.tint(Theme.red, 0.28)
                        }
                        Row {
                            anchors.centerIn: parent
                            spacing: 8
                            Icon { anchors.verticalCenter: parent.verticalCenter; name: "reset"; size: 16; color: Theme.red }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Hold to reset to default")
                                color: Theme.red
                                font.family: Theme.fontFamily
                                font.pixelSize: 15
                                font.weight: Font.DemiBold
                            }
                        }
                        NumberAnimation { id: holdAnim; target: hold; property: "progress"; from: 0; to: 1; duration: 1300 }
                        NumberAnimation { id: holdBack; target: hold; property: "progress"; to: 0; duration: 350 }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: { holdBack.stop(); holdAnim.restart() }
                            onReleased: { if (hold.progress < 1) { holdAnim.stop(); holdBack.restart() } }
                            onCanceled: { holdAnim.stop(); holdBack.restart() }
                        }
                        onProgressChanged: {
                            if (progress >= 1) {
                                holdAnim.stop()
                                root.app.applyPreset(ParamDefs.profiles.Default)
                                root.app.island(qsTr("Reset"), qsTr("Back to 500 / 50 / 0 ms"), "green", "reset")
                                holdBack.restart()
                            }
                        }
                    }
                }

                // ── эффективная задержка ──
                Panel {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.horizontalStretchFactor: 5
                    Layout.alignment: Qt.AlignTop
                    pop: 2

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: qsTr("Effective latency"); color: Theme.label; font.family: Theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold }
                        Text { text: qsTr("What a client feels per request"); color: Theme.label2; font.family: Theme.fontFamily; font.pixelSize: 14 }
                    }

                    Repeater {
                        model: [
                            { name: qsTr("AT command"), base: root.atD },
                            { name: qsTr("PID request"), base: root.obdD }
                        ]
                        delegate: ColumnLayout {
                            id: lat
                            readonly property real endPct: Math.max(0, Math.min(1, modelData.base / 3000))
                            Layout.fillWidth: true
                            Layout.topMargin: 18
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: modelData.name; color: Theme.label; font.family: Theme.fontFamily; font.pixelSize: 15 }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: Math.max(0, modelData.base - root.jitD) + "–" + (modelData.base + root.jitD) + " ms"
                                    color: Theme.label
                                    font.family: Theme.monoFamily
                                    font.pixelSize: 14
                                }
                            }
                            Rectangle {
                                id: track
                                Layout.fillWidth: true
                                Layout.preferredHeight: 16
                                radius: 8
                                color: Theme.fill
                                Rectangle {
                                    height: parent.height
                                    width: parent.width * lat.endPct
                                    radius: 8
                                    color: Theme.accent
                                    Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }
                                }
                                Rectangle { // диапазон джиттера
                                    y: -4
                                    height: parent.height + 8
                                    radius: 6
                                    color: Theme.label
                                    opacity: 0.85
                                    x: parent.width * Math.max(0, (modelData.base - root.jitD) / 3000)
                                    width: Math.max(3, parent.width * Math.min(1, (modelData.base + root.jitD) / 3000) - x)
                                    Behavior on x { NumberAnimation { duration: 600; easing.type: Easing.OutBack } }
                                    Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutBack } }
                                }
                                Rectangle { // летящий «пакет»
                                    id: pkt
                                    width: 12; height: 12; radius: 6
                                    y: 2
                                    x: -6
                                    color: "white"
                                    opacity: 0
                                    border.width: 3
                                    border.color: Theme.tint(Theme.accent, 0.45)
                                    SequentialAnimation {
                                        id: fly
                                        running: root.visible
                                        loops: Animation.Infinite
                                        PauseAnimation { duration: 400 }
                                        ParallelAnimation {
                                            NumberAnimation { target: pkt; property: "x"; from: -6; to: track.width * lat.endPct - 6; duration: 700 + lat.endPct * 1200; easing.type: Easing.OutCubic }
                                            SequentialAnimation {
                                                NumberAnimation { target: pkt; property: "opacity"; to: 1; duration: 80 }
                                                PauseAnimation { duration: 600 + lat.endPct * 1200 }
                                                NumberAnimation { target: pkt; property: "opacity"; to: 0; duration: 220 }
                                            }
                                        }
                                        PauseAnimation { duration: 1500 }
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 8
                        Repeater {
                            model: ["0", "1 s", "2 s", "3 s"]
                            delegate: Text {
                                Layout.fillWidth: true
                                horizontalAlignment: index === 0 ? Text.AlignLeft : (index === 3 ? Text.AlignRight : Text.AlignHCenter)
                                text: modelData
                                color: Theme.label3
                                font.family: Theme.monoFamily
                                font.pixelSize: 12
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 26
                        Layout.bottomMargin: 8
                        Text { text: qsTr("Last 30 PID replies"); color: Theme.label; font.family: Theme.fontFamily; font.pixelSize: 15; font.weight: Font.DemiBold }
                        Item { Layout.fillWidth: true }
                        Text {
                            id: avg
                            property real total: 0
                            text: qsTr("avg %1 ms").arg(Math.round(total))
                            color: Theme.label2
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            Connections {
                                target: hist
                                function onCountChanged() { avg.recalc() }
                            }
                            function recalc() {
                                var t = 0
                                for (var i = 0; i < hist.count; ++i) t += hist.get(i).v
                                total = hist.count ? t / hist.count : 0
                            }
                            Component.onCompleted: recalc()
                        }
                    }

                    Row {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 84
                        spacing: 3
                        readonly property real mx: {
                            var m = Math.max(200, root.obdD + root.jitD)
                            for (var i = 0; i < hist.count; ++i) m = Math.max(m, hist.get(i).v)
                            return m
                        }
                        Repeater {
                            model: hist
                            delegate: Item {
                                width: (parent.width - 29 * 3) / 30
                                height: parent.height
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: Math.max(4, parent.height * model.v / parent.parent.mx)
                                    radius: 3
                                    color: index === hist.count - 1 ? Theme.accent : Theme.tint(Theme.accent, 0.75)
                                    Behavior on height { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
