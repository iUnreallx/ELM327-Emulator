import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/// Нижняя панель для ввода точного значения параметра
Rectangle {
    id: root

    required property var app
    property string key: "speed"
    property bool shown: false
    readonly property var def: ParamDefs.defs[key]
    signal closeRequested()

    function openFor(k) {
        key = k
        field.typed = app.format(k)
        focusTimer.restart()
    }

    width: Math.min(440, parent ? parent.width : 440)
    height: col.implicitHeight + 38
    radius: 28
    color: Theme.surface
    x: parent ? (parent.width - width) / 2 : 0
    y: shown ? parent.height - height + radius : parent.height + 20
    // нижние скругления прячем за краем окна
    Behavior on y { NumberAnimation { duration: 550; easing.type: Easing.OutBack; easing.overshoot: 1.1 } }

    Timer { id: focusTimer; interval: 260; onTriggered: { field.forceActiveFocus(); field.selectAll() } }

    ColumnLayout {
        id: col
        x: 22
        y: 10
        width: parent.width - 44
        spacing: 0

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 38
            Layout.preferredHeight: 5
            radius: 3
            color: Theme.fill2
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 14
            text: root.def.title
            color: Theme.label
            font.family: Theme.fontFamily
            font.pixelSize: 18
            font.weight: Font.Bold
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: (root.def.pid !== "" ? "PID " + root.def.pid + " · " : "") + "range " + root.def.from + " – " + root.def.to + " " + root.def.unit
            color: Theme.label2
            font.family: Theme.fontFamily
            font.pixelSize: 14
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            Layout.bottomMargin: 14
            spacing: 8

            TextInput {
                id: field
                property string typed: ""
                Layout.preferredWidth: 190
                horizontalAlignment: TextInput.AlignRight
                text: activeFocus ? typed : root.app.format(root.key)
                color: Theme.label
                font.family: Theme.fontFamily
                font.pixelSize: 64
                font.weight: Font.Bold
                font.letterSpacing: -3
                selectionColor: Theme.accent
                selectByMouse: true
                inputMethodHints: Qt.ImhFormattedNumbersOnly

                onActiveFocusChanged: if (activeFocus) typed = root.app.format(root.key)
                onTextEdited: {
                    typed = text
                    var v = parseFloat(text.replace(",", "."))
                    if (!isNaN(v)) root.app.setValue(root.key, v)
                }
                Keys.onEscapePressed: root.closeRequested()
                Keys.onReturnPressed: root.closeRequested()
                Keys.onEnterPressed: root.closeRequested()
            }
            Text {
                Layout.alignment: Qt.AlignBottom
                Layout.bottomMargin: 10
                text: root.def.unit
                color: Theme.label2
                font.family: Theme.fontFamily
                font.pixelSize: 20
                font.weight: Font.Medium
            }
        }

        Stepper {
            Layout.alignment: Qt.AlignHCenter
            onStep: function (dir) { root.app.setValue(root.key, root.app.value(root.key) + dir * root.def.step) }
        }

        AppButton {
            Layout.fillWidth: true
            Layout.topMargin: 18
            size: "lg"
            kind: "filled"
            text: qsTr("Done")
            onClicked: root.closeRequested()
        }
    }
}
