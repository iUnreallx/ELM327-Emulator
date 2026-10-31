import QtQuick
import QtQuick.Layouts

/// Группа ячеек (inset grouped list). Внутрь кладутся Cell.
Rectangle {
    id: root

    default property alias content: column.data
    property bool locked: false

    implicitHeight: column.implicitHeight
    radius: Theme.rMd
    color: Theme.group
    clip: true
    opacity: locked ? 0.55 : 1
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on color { ColorAnimation { duration: 300 } }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0
    }
}
