import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

/// Плитка-кольцо (Overview): иконка, кольцо активности с одометром и ползунок.
Panel {
    id: root

    property var app
    property string key: "temp"
    readonly property var def: ParamDefs.defs[key]
    readonly property real current: app.value(key)
    readonly property bool warn: current >= def.warn
    readonly property color tone: warn ? Theme.red : Theme[def.tone]

    padding: 22

    property real shown: app.fraction(key)
    Behavior on shown { NumberAnimation { duration: 1000; easing.type: Easing.OutBack; easing.overshoot: 0.9 } }

    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            radius: 10
            color: Theme[root.def.tone]
            Icon { anchors.centerIn: parent; name: root.def.icon; size: 17; color: "white" }
        }
        Text {
            Layout.fillWidth: true
            text: root.def.title
            color: Theme.label
            font.family: Theme.fontFamily
            font.pixelSize: 15
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
        Text {
            text: root.def.pid
            color: Theme.label2
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.letterSpacing: 0.8
        }
    }

    Item {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 14
        Layout.preferredWidth: 132
        Layout.preferredHeight: 132

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 8
            ShapePath {
                strokeColor: Theme.fill
                strokeWidth: 13
                fillColor: "transparent"
                PathAngleArc { centerX: 66; centerY: 66; radiusX: 56; radiusY: 56; startAngle: -90; sweepAngle: 359.9 }
            }
            ShapePath {
                strokeColor: root.tone
                strokeWidth: 13
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                Behavior on strokeColor { ColorAnimation { duration: 300 } }
                PathAngleArc { centerX: 66; centerY: 66; radiusX: 56; radiusY: 56; startAngle: -90; sweepAngle: Math.max(0.01, 359.9 * root.shown) }
            }
        }

        Column {
            anchors.centerIn: parent
            Odo {
                anchors.horizontalCenter: parent.horizontalCenter
                pixelSize: 30
                value: root.current
                decimals: root.def.dec
                clickable: true
                onClicked: root.app.editRequested(root.key)
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.def.unit
                color: Theme.label2
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
        }
    }

    AppSlider {
        Layout.fillWidth: true
        Layout.topMargin: 14
        from: root.def.from
        to: root.def.to
        stepSize: root.def.step
        value: root.current
        onMoved: root.app.setValue(root.key, value)
    }
}
