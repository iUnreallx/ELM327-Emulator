import QtQuick
import QtQuick.Controls.Basic

ScrollBar {
    id: bar
    implicitWidth: 10
    padding: 2
    policy: ScrollBar.AsNeeded

    contentItem: Rectangle {
        implicitWidth: 6
        implicitHeight: 40
        radius: 3
        color: Theme.fill2
        opacity: bar.active || bar.hovered ? 1 : 0.5
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
    background: Item {}
}
