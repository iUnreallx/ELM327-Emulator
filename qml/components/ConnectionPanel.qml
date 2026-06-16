import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    // 0 - WIFI, 1 - Bluetooth, 2 - USB
    property int activeMode: 0

    property bool isConnected: true
    property string statusText: isConnected ? qsTr("Emulator is ready.")
                                            : qsTr("Waiting for connection...")

    Layout.fillWidth: true
    Layout.preferredHeight: 180
    color: "#0B1120"
    border.color: "#1E293B"
    border.width: 1
    radius: 12
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 15

        Text {
            text: qsTr("CONNECTION")
            color: "#94A3B8"
            font.pixelSize: 12
            font.bold: true
            font.letterSpacing: 2
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            /// правая часть ( выбор ком порта или ip )
            RowLayout {
                id: rightPanel
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 30

                // Разделительная линия
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: "#1E293B"
                }

                // Правые настройки
                ColumnLayout {
                    Layout.alignment: Qt.AlignTop
                    spacing: 20

                    StackLayout {
                        currentIndex: activeMode === 0 ? 0 : 1

                        RowLayout {
                            spacing: 40

                            ColumnLayout {
                                Text { text: qsTr("IP ADDRESS"); color: "#64748B"; font.pixelSize: 10; font.bold: true }
                                TextField {
                                    text: "192.168.1.50"
                                    color: "white"
                                    font.pixelSize: 14
                                    background: Rectangle { color: "#1E293B"; radius: 4; implicitHeight: 30; implicitWidth: 150 }
                                }
                            }

                            ColumnLayout {
                                Text { text: qsTr("PORT"); color: "#64748B"; font.pixelSize: 10; font.bold: true }
                                TextField {
                                    text: "35000"
                                    color: "white"
                                    font.pixelSize: 14
                                    background: Rectangle { color: "#1E293B"; radius: 4; implicitHeight: 30; implicitWidth: 100 }
                                }
                            }
                        }

                        RowLayout {
                            ColumnLayout {
                                Text { text: qsTr("COM PORT"); color: "#64748B"; font.pixelSize: 10; font.bold: true }
                                TextField {
                                    placeholderText: qsTr("e.g. COM3 or /dev/ttyUSB0")
                                    color: "white"
                                    font.pixelSize: 14
                                    background: Rectangle {
                                        color: "#1E293B";
                                        radius: 4;
                                        implicitHeight: 30;
                                        implicitWidth: 290
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        spacing: 40

                        ColumnLayout {
                            Text { text: qsTr("PROTOCOL"); color: "#64748B"; font.pixelSize: 10; font.bold: true }
                            Text { text: "ISO 15765-4 (CAN 11/500)"; color: "white"; font.pixelSize: 14 }
                        }

                        ColumnLayout {
                            Text { text: qsTr("ADAPTER"); color: "#64748B"; font.pixelSize: 10; font.bold: true }
                            Text { text: "ELM327 v1.5"; color: "white"; font.pixelSize: 14 }
                        }
                    }
                }
            }

            /// выбор типа подключения
            ColumnLayout {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: rightPanel.left
                anchors.rightMargin: 40
                spacing: 5

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: "transparent"
                    border.color: "#1E293B"
                    radius: 6

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        /// wifi
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: activeMode === 0 ? "#1E293B" : "transparent"
                            radius: 6

                            Text {
                                anchors.centerIn: parent
                                text: "Wi-Fi"
                                color: activeMode === 0 ? "#38BDF8" : "#94A3B8"
                                font.bold: activeMode === 0
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: activeMode = 0
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        /// Bluetooth
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: activeMode === 1 ? "#1E293B" : "transparent"
                            radius: 6

                            Text {
                                anchors.centerIn: parent
                                text: "Bluetooth"
                                color: activeMode === 1 ? "#38BDF8" : "#94A3B8"
                                font.bold: activeMode === 1
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: activeMode = 1
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        /// USB
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: activeMode === 2 ? "#1E293B" : "transparent"
                            radius: 6

                            Text {
                                anchors.centerIn: parent
                                text: "USB"
                                color: activeMode === 2 ? "#38BDF8" : "#94A3B8"
                                font.bold: activeMode === 2
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: activeMode = 2
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }

                /// status
                ColumnLayout {
                    spacing: 2

                    RowLayout {
                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: isConnected ? "#41CD52" : "#F44336"
                        }

                        Text {
                            text: isConnected ? qsTr("Connected") : qsTr("Disconnected")
                            color: isConnected ? "#41CD52" : "#F44336"
                            font.bold: true
                        }
                    }

                    Text {
                        text: root.statusText
                        color: "#94A3B8"
                        font.pixelSize: 12
                    }

                    Item {
                        height: 4.5
                    }

                    /// button start / stop
                    Rectangle {
                        id: actionButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: 6

                        color: isConnected ? "#E11D48" : "#10B981"

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }
                        }

                        transformOrigin: Item.Center
                        scale: startMouseArea.pressed ? 0.96 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: isConnected ? qsTr("STOP SERVER") : qsTr("START SERVER")
                            color: "#FFFFFF"
                            font.bold: true
                            font.pixelSize: 12
                            font.letterSpacing: 1
                        }

                        MouseArea {
                            id: startMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.isConnected = !root.isConnected
                            }
                        }
                    }
                }
            }
        }
    }
}
