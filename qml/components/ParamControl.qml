import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/// Ползунок с подписями min/max и степпером справа. Работает с app.value(key) / app.setValue().
RowLayout {
    id: root

    required property var app
    property string key: "speed"
    readonly property var def: ParamDefs.defs[key]
    readonly property real current: app.value(key)

    spacing: 12

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 0

        Slider {
            id: s
            Layout.fillWidth: true
            implicitHeight: 28
            from: root.def.from
            to: root.def.to
            stepSize: root.def.step
            value: root.current
            focusPolicy: Qt.NoFocus
            onMoved: root.app.setValue(root.key, value)

            background: Rectangle {
                x: s.leftPadding
                y: s.topPadding + (s.availableHeight - height) / 2
                width: s.availableWidth
                height: 4
                radius: 2
                color: Theme.fill2

                Rectangle {
                    width: s.visualPosition * parent.width
                    height: parent.height
                    radius: 2
                    color: Theme.accent
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
            }

            handle: Item {
                x: s.leftPadding + s.visualPosition * (s.availableWidth - width)
                y: s.topPadding + (s.availableHeight - height) / 2
                width: 28
                height: 28
                scale: s.pressed ? 1.12 : 1
                Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }

                Rectangle { // мягкая тень
                    anchors.fill: parent
                    anchors.topMargin: 4
                    anchors.leftMargin: -1
                    anchors.rightMargin: -1
                    anchors.bottomMargin: -4
                    radius: width / 2
                    color: "#26000000"
                }
                Rectangle { anchors.fill: parent; radius: width / 2; color: "white" }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: -4
            Text {
                text: root.def.from
                color: Theme.label3
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
            Item { Layout.fillWidth: true }
            Text {
                text: root.def.to
                color: Theme.label3
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
        }
    }

    Stepper {
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: -2
        onStep: function (dir) { root.app.setValue(root.key, root.app.value(root.key) + dir * root.def.step) }
    }
}
