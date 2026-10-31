import QtQuick
import QtQuick.Layouts

/// Ячейка списка: заголовок слева, значение справа, любой доп. контент (поле, шеврон…) — внутрь.
Item {
    id: root

    default property alias content: row.data
    property string title: ""
    property string valueText: ""
    property bool mono: false
    property bool first: false
    property bool tappable: false
    property bool locked: false
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 46

    Rectangle { // подсветка при нажатии
        anchors.fill: parent
        visible: root.tappable
        color: tap.pressed ? Theme.fill2 : (tap.containsMouse ? Theme.fill : "transparent")
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Rectangle { // разделитель
        visible: !root.first
        x: 16
        width: parent.width - 16
        height: 1
        color: Theme.separator
        opacity: 0.6
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        Text {
            Layout.fillWidth: true
            text: root.title
            color: Theme.label
            font.family: Theme.fontFamily
            font.pixelSize: 16
            elide: Text.ElideRight
        }
        Text {
            visible: root.valueText !== ""
            text: root.valueText
            color: Theme.label2
            font.family: root.mono ? Theme.monoFamily : Theme.fontFamily
            font.pixelSize: 16
            horizontalAlignment: Text.AlignRight
        }
    }

    MouseArea {
        id: tap
        anchors.fill: parent
        enabled: root.tappable
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
