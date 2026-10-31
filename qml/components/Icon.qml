import QtQuick
import QtQuick.Controls

/// Иконка из qml/assets/icons/<name>.svg, окрашивается в `color`.
Item {
    id: root

    property string name: ""
    property real size: 20
    property color color: Theme.label2

    implicitWidth: size
    implicitHeight: size

    IconImage {
        anchors.fill: parent
        source: root.name === "" ? "" : "../assets/icons/" + root.name + ".svg"
        sourceSize: Qt.size(Math.ceil(root.size * 3), Math.ceil(root.size * 3))
        color: root.color
        Behavior on color { ColorAnimation { duration: 180 } }
    }
}
