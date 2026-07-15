import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    component DelayCard: Rectangle {
        id: card

        property string title: ""
        property string description: ""

        property int fromValue: 0
        property int toValue: 1000
        property int stepValue: 10
        property int currentValue: 0

        signal valueChangedByUser(int newValue)

        Layout.fillWidth: true
        Layout.minimumWidth: 220
        Layout.preferredHeight: 180

        color: "#0D1520"
        border.color: "#1E293B"
        border.width: 1
        radius: 12

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Text {
                        text: card.title
                        color: "#F8FAFC"

                        font.pixelSize: 16
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true

                        text: card.description
                        color: "#64748B"

                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                    }
                }

                Rectangle {
                    Layout.preferredWidth: valueLabel.implicitWidth + 20
                    Layout.preferredHeight: 34

                    color: "#0B2535"
                    border.color: "#164E63"
                    border.width: 1
                    radius: 7

                    Text {
                        id: valueLabel
                        anchors.centerIn: parent

                        text: Math.round(delaySlider.value) + " ms"
                        color: "#38BDF8"

                        font.pixelSize: 14
                        font.bold: true
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }

            Slider {
                id: delaySlider

                Layout.fillWidth: true
                Layout.preferredHeight: 26

                from: card.fromValue
                to: card.toValue
                stepSize: card.stepValue
                value: card.currentValue

                snapMode: Slider.SnapAlways
                live: true
                focusPolicy: Qt.NoFocus

                onMoved: {
                    card.valueChangedByUser(Math.round(value))
                }

                background: Rectangle {
                    x: delaySlider.leftPadding

                    y: delaySlider.topPadding
                       + (delaySlider.availableHeight - height) / 2

                    width: delaySlider.availableWidth
                    height: 5

                    color: "#1E293B"
                    radius: 3

                    Rectangle {
                        width: delaySlider.visualPosition * parent.width
                        height: parent.height

                        color: "#38BDF8"
                        radius: parent.radius
                    }
                }

                handle: Rectangle {
                    x: delaySlider.leftPadding
                       + delaySlider.visualPosition
                       * (delaySlider.availableWidth - width)

                    y: delaySlider.topPadding
                       + (delaySlider.availableHeight - height) / 2

                    implicitWidth: 18
                    implicitHeight: 18

                    color: delaySlider.pressed
                           ? "#FFFFFF"
                           : "#38BDF8"

                    border.color: "#070E16"
                    border.width: 2
                    radius: 9

                    scale: delaySlider.pressed ? 1.15 : 1.0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 100
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: card.fromValue + " ms"
                    color: "#475569"
                    font.pixelSize: 10
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: card.toValue + " ms"
                    color: "#475569"
                    font.pixelSize: 10
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    text: qsTr("Response Delay")
                    color: "#F8FAFC"

                    font.pixelSize: 25
                    font.bold: true
                }

                Text {
                    text: qsTr("Configure emulator response timing")
                    color: "#64748B"
                    font.pixelSize: 13
                }
            }  Item {
                Layout.fillWidth: true
            }


            Rectangle {
                id: resetButton

                Layout.preferredWidth: 120
                Layout.preferredHeight: 36
                Layout.alignment: Qt.AlignRight

                color: resetMouseArea.pressed
                       ? "#1E293B"
                       : resetMouseArea.containsMouse
                         ? "#16202D"
                         : "#0D1520"

                border.color: resetMouseArea.containsMouse
                              ? "#38BDF8"
                              : "#334155"

                border.width: 1
                radius: 7

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 120
                    }
                }

                Text {
                    anchors.centerIn: parent

                    text: qsTr("RESET")

                    color: resetMouseArea.containsMouse
                           ? "#FFFFFF"
                           : "#94A3B8"

                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 1

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }
                    }
                }

                MouseArea {
                    id: resetMouseArea

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        globalToast.show("Параметры восстановлены", false);
                        delayManager.atDelay = 500
                        delayManager.obdDelay = 50
                        delayManager.jitter = 0
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true

            columns: width >= 760 ? 3
                                 : width >= 500 ? 2
                                                : 1

            columnSpacing: 14
            rowSpacing: 14

            DelayCard {
                title: qsTr("AT Commands")
                description: qsTr("Delay for ATZ, ATE0, ATRV and other AT commands")

                fromValue: 0
                toValue: 2000
                stepValue: 10

                currentValue: delayManager.atDelay

                onValueChangedByUser: function(newValue) {
                    delayManager.atDelay = newValue
                }
            }

            DelayCard {
                title: qsTr("OBD2 Requests")
                description: qsTr("Delay for RPM, speed and other PID responses")

                fromValue: 0
                toValue: 1000
                stepValue: 10

                currentValue: delayManager.obdDelay

                onValueChangedByUser: function(newValue) {
                    delayManager.obdDelay = newValue
                }
            }

            DelayCard {
                title: qsTr("Random Jitter")
                description: qsTr("Random variation added to response delay")

                fromValue: 0
                toValue: 500
                stepValue: 5

                currentValue: delayManager.jitter

                onValueChangedByUser: function(newValue) {
                    delayManager.jitter = newValue
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
