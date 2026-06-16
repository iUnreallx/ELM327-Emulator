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

    readonly property int maxHistoryPoints: 100
    readonly property color highlightColor: "#38BDF8"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 5

        Text {
            text: root.title
            color: "#94A3B8"
            font.pixelSize: 14
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
