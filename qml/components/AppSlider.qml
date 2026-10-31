import QtQuick
import QtQuick.Controls.Basic

/// Тонкий ползунок: акцентная дорожка, белая ручка с пружиной
Slider {
    id: s

    implicitHeight: 28
    focusPolicy: Qt.NoFocus

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
        }
    }

    handle: Item {
        x: s.leftPadding + s.visualPosition * (s.availableWidth - width)
        y: s.topPadding + (s.availableHeight - height) / 2
        width: 28
        height: 28
        scale: s.pressed ? 1.12 : 1
        Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }

        Rectangle {
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
