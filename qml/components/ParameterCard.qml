// components/ParameterCard.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/// карточки параметров эбу
Rectangle {
    id: root
    color: "#101823"
    radius: 10
    clip: true

    property string title: qsTr("Parameter")
    property string unit: ""
    property real minValue: 0
    property real maxValue: 100
    property real step: 1

    property var history: []
    property alias value: internalSlider.value
    property url iconSource: ""
    property int sizeVariant: 0

    readonly property int maxHistoryPoints: 100
    readonly property color highlightColor: "#38BDF8"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            IconImage {
                source: root.iconSource
                visible: root.iconSource.toString() !== ""
                Layout.preferredWidth: 20 + sizeVariant
                Layout.preferredHeight: 20 + sizeVariant
                color: "#94A3B8"
                opacity: 0.7
                Layout.alignment: Qt.AlignVCenter
            }
            Text {
                text: root.title
                color: "#94A3B8"
                font.pixelSize: 14
            }
        }

        RowLayout {
            spacing: 5
            Text {
                text: Number(root.value).toFixed(root.step < 1 ? 1 : 0)
                color: "white"
                font.pixelSize: 32
                font.bold: true
                Layout.alignment: Qt.AlignBottom
            }
            Text {
                text: root.unit
                color: "#94A3B8"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 4
            }
        }

        SparklineGraph {
            id: sparkline
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            historyData: root.history
            minValue: root.minValue
            maxValue: root.maxValue
        }

        Slider {
            id: internalSlider
            from: root.minValue
            to: root.maxValue
            stepSize: root.step
            Layout.fillWidth: true

            focusPolicy: Qt.NoFocus

            background: Rectangle {
                x: internalSlider.leftPadding
                y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
                implicitWidth: 200
                implicitHeight: 4
                width: internalSlider.availableWidth
                height: implicitHeight
                radius: 2
                color: "#1E293B"


                Rectangle {
                    width: internalSlider.visualPosition * parent.width
                    height: parent.height
                    color: "#38BDF8"
                    radius: 2
                }
            }

            handle: Rectangle {
                x: internalSlider.leftPadding + internalSlider.visualPosition * (internalSlider.availableWidth - width)
                y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
                implicitWidth: 14
                implicitHeight: 14
                radius: 7

                color: (internalSlider.pressed || hoverSlider.hovered) ? "#FFFFFF" : "#38BDF8"

                border.color: internalSlider.pressed ? "#070E16" : "transparent"
                border.width: 2

                Behavior on color { ColorAnimation { duration: 100 } }

                HoverHandler {
                    id: hoverSlider
                    cursorShape: Qt.PointingHandCursor
                }
            }

            onValueChanged: {
                root.history.push(value)
                if (root.history.length > root.maxHistoryPoints) {
                    root.history.shift()
                }
                sparkline.requestPaint()
            }
        }
    }
}
