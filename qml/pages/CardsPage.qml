import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../components"

PageBase {
    id: root

    required property var app

    readonly property real contentW: Math.min(flick.width - Theme.pagePadding * 2, 1320 - Theme.pagePadding * 2)
    readonly property int tileCols: contentW > 1100 ? 6 : (contentW > 640 ? 3 : 2)

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
                title: qsTr("Parameters")
                subtitle: qsTr("Drag a tile to change a value, tap the number to type")
            }

            Panel {
                Layout.fillWidth: true
                pop: 0
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text { text: qsTr("Scenario"); color: Theme.label; font.family: Theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold }
                    Text { text: qsTr("Start from a preset, then fine-tune below"); color: Theme.label2; font.family: Theme.fontFamily; font.pixelSize: 14 }
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
            }

            GridLayout {
                Layout.fillWidth: true
                columns: root.tileCols
                columnSpacing: 14
                rowSpacing: 14

                Repeater {
                    model: ParamDefs.order
                    delegate: VerticalTile {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        app: root.app
                        key: modelData
                        pop: index + 1
                    }
                }
            }

            Panel {
                Layout.fillWidth: true
                pop: 8
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 14
                    spacing: 2
                    Text { text: qsTr("Live response"); color: Theme.label; font.family: Theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold }
                    Text { text: qsTr("What a client receives for each PID right now"); color: Theme.label2; font.family: Theme.fontFamily; font.pixelSize: 14 }
                }
                Group {
                    Layout.fillWidth: true
                    Repeater {
                        model: ParamDefs.order
                        delegate: Item {
                            readonly property var def: ParamDefs.defs[modelData]
                            Layout.fillWidth: true
                            implicitHeight: 46
                            Rectangle { visible: index > 0; x: 16; width: parent.width - 16; height: 1; color: Theme.separator; opacity: 0.6 }
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 12
                                Rectangle {
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28
                                    radius: 8
                                    color: Theme[def.tone]
                                    Icon { anchors.centerIn: parent; name: def.icon; size: 15; color: "white" }
                                }
                                Text {
                                    text: def.title
                                    color: Theme.label
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 16
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: def.pid
                                    color: Theme.label2
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 13
                                }
                                Text {
                                    text: ParamDefs.response(modelData, root.app.value(modelData))
                                    color: Theme.label
                                    font.family: Theme.monoFamily
                                    font.pixelSize: 15
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
