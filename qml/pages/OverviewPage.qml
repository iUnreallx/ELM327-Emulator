import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Basic as Basic
import "../components"

Item {
    id: root

    ScrollView {
        id: scrollView
        anchors.fill: parent
        clip: true

        ScrollBar.vertical.policy: ScrollBar.AlwaysOff
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            id: outerColumn
            x: 20
            width: scrollView.availableWidth - 40
            spacing: 0

            Item { Layout.preferredHeight: 20 }

            ColumnLayout {
                id: pageColumn
                Layout.fillWidth: true
                spacing: 20

                /// connection panel data
                ConnectionPanel {
                    Layout.fillWidth: true
                }

                /// LIVE DATA, ДАННЫЕ С ЭБУ В ЛИНИЮ
                Rectangle {
                    id: liveDataPanel
                    Layout.fillWidth: true
                    Layout.preferredHeight: 210
                    color: "#0B1120"
                    border.color: "#1E293B"
                    border.width: 1
                    radius: 12
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                            RowLayout {
                                Layout.fillWidth: true

                            Text {
                                text: qsTr("LIVE DATA")
                                color: "#94A3B8"
                                font.pixelSize: 12
                                font.bold: true
                                font.letterSpacing: 2
                                font.capitalization: Font.AllUppercase
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: qsTr("View all >")
                                color: "#38BDF8"
                                font.pixelSize: 12
                                font.bold: true

                                MouseArea {
                                    id: viewAllClick
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        pageStack.currentIndex = 2
                                    }
                                }
                            }
                        }

                        /// список из четырёх карточек
                        Flow {
                            id: cardsFlow
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 12
                            flow: Flow.LeftToRight

                            property real cardWidth: Math.max(180, (width - (spacing * 3)) / 4)

                            ParameterCard {
                                width: cardsFlow.cardWidth
                                height: liveDataPanel.height - 60
                                title: qsTr("Vehicle Speed")
                                unit: qsTr("km/h")
                                iconSource: "../assets/parametersCard/speed.svg"
                                minValue: 0
                                maxValue: 255
                                step: 1
                                value: ecuModel.speed
                                onValueChanged: ecuModel.speed = value
                            }

                            ParameterCard {
                                width: cardsFlow.cardWidth
                                height: liveDataPanel.height - 60
                                title: qsTr("Engine RPM")
                                unit: qsTr("rpm")
                                iconSource: "../assets/parametersCard/engine.svg"
                                minValue: 0
                                sizeVariant: 1
                                maxValue: 15000
                                step: 50
                                value: ecuModel.rpm
                                onValueChanged: ecuModel.rpm = value
                            }

                            ParameterCard {
                                width: cardsFlow.cardWidth
                                height: liveDataPanel.height - 60
                                title: qsTr("Coolant Temp")
                                unit: qsTr("°C")
                                iconSource: "../assets/parametersCard/temp.svg"
                                sizeVariant: 1
                                minValue: -40
                                maxValue: 150
                                step: 1
                                value: 89
                            }

                            ParameterCard {
                                width: cardsFlow.cardWidth
                                height: liveDataPanel.height - 60
                                title: qsTr("Battery Voltage")
                                unit: qsTr("V")
                                sizeVariant: 2
                                iconSource: "../assets/parametersCard/voltage.svg"
                                minValue: 0
                                maxValue: 18
                                step: 0.1
                                value: 13.7
                            }
                        }
                    }
                } /// конец пункта live даты

                /// панель логирование
                LogsPanel {
                    Layout.fillWidth: true
                }
            }

            Item { Layout.preferredHeight: 20 }
        }
    }
}
