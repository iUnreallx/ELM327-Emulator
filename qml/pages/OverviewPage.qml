import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../components"

PageBase {
    id: root

    required property var app
    signal goTo(int index)

    readonly property real contentW: Math.min(flick.width - Theme.pagePadding * 2, 1320 - Theme.pagePadding * 2)
    readonly property bool wide: contentW > 1100
    readonly property int logCount: app.logModel.count

    scrollY: flick.contentY

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
                title: qsTr("Overview")
                subtitle: qsTr("Live ECU values the emulator reports")
            }

            // ── спидометры ──
            Panel {
                Layout.fillWidth: true
                padding: 0
                pop: 0

                GridLayout {
                    Layout.fillWidth: true
                    columns: root.contentW > 760 ? 2 : 1
                    columnSpacing: 0
                    rowSpacing: 0

                    Repeater {
                        model: ["speed", "rpm"]
                        delegate: RowLayout {
                            id: cell
                            readonly property var def: ParamDefs.defs[modelData]
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.alignment: Qt.AlignTop
                            spacing: 0

                            Rectangle {
                                visible: index > 0 && root.contentW > 760
                                Layout.preferredWidth: 1
                                Layout.fillHeight: true
                                color: Theme.separator
                                opacity: 0.6
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: 28
                                Layout.rightMargin: 28
                                Layout.topMargin: 22
                                Layout.bottomMargin: 24
                                spacing: 0

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12
                                    Rectangle {
                                        Layout.preferredWidth: 34
                                        Layout.preferredHeight: 34
                                        radius: 10
                                        color: Theme[cell.def.tone]
                                        Icon { anchors.centerIn: parent; name: cell.def.icon; size: 18; color: "white" }
                                    }
                                    ColumnLayout {
                                        spacing: 0
                                        Text {
                                            text: cell.def.title
                                            color: Theme.label
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 17
                                            font.weight: Font.DemiBold
                                        }
                                        Text {
                                            text: "PID " + cell.def.pid
                                            color: Theme.label2
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 14
                                        }
                                    }
                                    Item { Layout.fillWidth: true }
                                    Stepper {
                                        onStep: function (dir) { root.app.setValue(modelData, root.app.value(modelData) + dir * cell.def.step * (cell.def.to > 1000 ? 10 : (cell.def.to > 100 ? 5 : 1))) }
                                    }
                                }

                                Gauge {
                                    Layout.fillWidth: true
                                    Layout.maximumWidth: 400
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.topMargin: 6
                                    value: root.app.value(modelData)
                                    from: cell.def.from
                                    to: cell.def.to
                                    warnAt: cell.def.warn
                                    decimals: cell.def.dec
                                    unit: cell.def.unit
                                    major: cell.def.major
                                    minor: cell.def.minor
                                    labelDiv: cell.def.labelDiv
                                    onEditRequested: root.app.editRequested(modelData)
                                }

                                AppSlider {
                                    Layout.fillWidth: true
                                    Layout.topMargin: 14
                                    from: cell.def.from
                                    to: cell.def.to
                                    stepSize: cell.def.step
                                    value: root.app.value(modelData)
                                    onMoved: root.app.setValue(modelData, value)
                                }
                            }
                        }
                    }
                }
            }

            // ── кольца ──
            GridLayout {
                Layout.fillWidth: true
                columns: root.wide ? 4 : (root.contentW > 640 ? 2 : 1)
                columnSpacing: Theme.gap
                rowSpacing: Theme.gap

                Repeater {
                    model: ParamDefs.statOrder
                    delegate: StatCard {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        app: root.app
                        key: modelData
                        pop: index + 1
                    }
                }
            }

            // ── статус + сценарии ──
            GridLayout {
                Layout.fillWidth: true
                columns: root.wide ? 2 : 1
                columnSpacing: Theme.gap
                rowSpacing: Theme.gap

                Panel {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.horizontalStretchFactor: 4
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    pop: 5

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 18
                        spacing: 16
                        StatusIcon { on: root.app.connected; tile: 60 }
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: root.app.connected ? qsTr("Server is live") : qsTr("Server stopped")
                                color: Theme.label
                                font.family: Theme.fontFamily
                                font.pixelSize: 22
                                font.weight: Font.Bold
                                font.letterSpacing: -0.6
                            }
                            Text {
                                text: root.app.connected ? root.app.endpoint : qsTr("Ready on ") + root.app.endpoint
                                color: Theme.label2
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                            }
                        }
                    }

                    Group {
                        Layout.fillWidth: true
                        Cell { first: true; title: qsTr("Uptime"); valueText: root.app.formatUptime(root.app.uptime) }
                        Cell {
                            title: qsTr("Requests (RX)")
                            Odo { pixelSize: 16; weight: Font.DemiBold; value: root.app.rxCount; countUp: false }
                        }
                        Cell {
                            title: qsTr("Responses (TX)")
                            Odo { pixelSize: 16; weight: Font.DemiBold; value: root.app.txCount; countUp: false }
                        }
                    }

                    Item { Layout.fillHeight: true; Layout.minimumHeight: 16 }

                    AppButton {
                        Layout.fillWidth: true
                        size: "lg"
                        kind: root.app.connected ? "red" : "filled"
                        iconName: root.app.connected ? "stop" : "power"
                        text: root.app.connected ? qsTr("Stop server") : qsTr("Start server")
                        onClicked: root.app.requestToggle()
                    }
                }

                Panel {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.horizontalStretchFactor: 8
                    Layout.alignment: Qt.AlignTop
                    pop: 6

                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            spacing: 2
                            Text { text: qsTr("Scenario"); color: Theme.label; font.family: Theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold }
                            Text { text: qsTr("One tap sets every parameter"); color: Theme.label2; font.family: Theme.fontFamily; font.pixelSize: 14 }
                        }
                        Item { Layout.fillWidth: true }
                        AppButton { size: "sm"; kind: "tinted"; text: qsTr("All parameters"); trailingIcon: "chevR"; onClicked: root.goTo(2) }
                    }

                    Flow {
                        Layout.fillWidth: true
                        Layout.topMargin: 14
                        spacing: 10
                        Repeater {
                            model: ParamDefs.scenarioOrder
                            delegate: ScenarioChip {
                                text: modelData
                                iconName: ParamDefs.scenarioIcons[modelData]
                                active: root.app.scenario === modelData
                                onClicked: root.app.applyScenario(modelData)
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 22
                        Layout.bottomMargin: 10
                        Text { text: qsTr("Latest traffic"); color: Theme.label; font.family: Theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold }
                        Item { Layout.fillWidth: true }
                        AppButton { size: "sm"; kind: "tinted"; text: qsTr("Open logs"); trailingIcon: "chevR"; onClicked: root.goTo(4) }
                    }

                    Group {
                        Layout.fillWidth: true
                        Repeater {
                            model: Math.min(4, root.logCount)
                            delegate: Item {
                                readonly property var item: root.app.logModel.get(root.logCount - 1 - index)
                                Layout.fillWidth: true
                                implicitHeight: 46
                                Rectangle { visible: index > 0; x: 16; width: parent.width - 16; height: 1; color: Theme.separator; opacity: 0.6 }
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    spacing: 12
                                    Badge {
                                        text: item.isRx ? "RX" : "TX"
                                        tone: item.isErr ? "red" : (item.isRx ? "green" : "gray")
                                        implicitHeight: 20
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: item.msg
                                        color: item.isErr ? Theme.red : Theme.label
                                        font.family: Theme.monoFamily
                                        font.pixelSize: 14
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: item.decoded
                                        color: Theme.label2
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 13
                                    }
                                }
                            }
                        }
                        Cell {
                            visible: root.logCount === 0
                            first: true
                            title: qsTr("Nothing yet. Start the server to see traffic.")
                        }
                    }
                }
            }
        }
    }
}
