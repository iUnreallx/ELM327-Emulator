import QtQuick

/// Одометр: цифры «прокручиваются» пружиной. При появлении страницы считает с нуля.
Item {
    id: root

    property real value: 0
    property int decimals: 0
    property int pixelSize: 40
    property color color: Theme.label
    property int weight: Font.Bold
    property real tracking: -pixelSize * 0.035
    property bool countUp: true
    property bool clickable: false
    signal clicked()

    property bool armed: !countUp
    readonly property real shown: armed ? value : 0
    readonly property string str: Number(shown).toFixed(decimals)
    readonly property int cellH: Math.round(pixelSize * 1.16)

    implicitWidth: row.width
    implicitHeight: cellH
    clip: true

    onVisibleChanged: {
        if (!countUp) return
        if (visible) { armed = false; arm.restart() }
    }
    Component.onCompleted: if (countUp && visible) arm.restart()
    Timer { id: arm; interval: 90; onTriggered: root.armed = true }

    TextMetrics {
        id: tm
        text: "0"
        font.family: Theme.fontFamily
        font.pixelSize: root.pixelSize
        font.weight: root.weight
    }

    Row {
        id: row
        height: root.cellH
        spacing: root.tracking

        Repeater {
            model: root.str.length
            delegate: Item {
                id: cell
                readonly property string ch: root.str.charAt(index)
                readonly property bool isDigit: ch >= "0" && ch <= "9"
                width: isDigit ? Math.ceil(tm.advanceWidth) : sep.implicitWidth
                height: root.cellH
                clip: true

                Column {
                    visible: cell.isDigit
                    y: -(cell.isDigit ? Number(cell.ch) : 0) * root.cellH
                    Behavior on y { NumberAnimation { duration: 900; easing.type: Easing.OutBack; easing.overshoot: 0.9 } }
                    Repeater {
                        model: 10
                        delegate: Text {
                            width: cell.width
                            height: root.cellH
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: index
                            color: root.color
                            font.family: Theme.fontFamily
                            font.pixelSize: root.pixelSize
                            font.weight: root.weight
                        }
                    }
                }
                Text {
                    id: sep
                    visible: !cell.isDigit
                    height: root.cellH
                    verticalAlignment: Text.AlignVCenter
                    text: cell.ch
                    color: root.color
                    font.family: Theme.fontFamily
                    font.pixelSize: root.pixelSize
                    font.weight: root.weight
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.clickable
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
