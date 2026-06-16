// components/SidebarButton.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

/// Это кнопки боковой панели, мы передаём три свойства
/// Текст, состояние активности, и лямбду при клике

Rectangle {
    id: root

    property string buttonText: qsTr("Menu Item")
    property bool isActive: false
    property bool isHovered: hoverHandler.hovered
    signal clicked()

    Layout.fillWidth: true
    Layout.preferredHeight: 45
    radius: 8

    readonly property color bgActive: "#1E293B"
    readonly property color bgActiveHover: "#2D3748"
    readonly property color bgInactive: "#001A2333"
    readonly property color bgInactiveHover: "#1A2333"

    readonly property color textActive: "#38BDF8"
    readonly property color textInactive: "#94A3B8"
    readonly property color textInactiveHover: "#FFFFFF"

    color: {
        if (root.isActive) return isHovered ? bgActiveHover : bgActive
        return isHovered ? bgInactiveHover : bgInactive
    }

    Behavior on color { ColorAnimation { duration: 150 } }

    RowLayout {
        anchors.centerIn: parent
        spacing: 12

        Text {
            text: root.buttonText
            color: {
                if (root.isActive) return textActive
                return isHovered ? textInactiveHover : textInactive
            }
            font.pixelSize: 15
            font.bold: root.isActive
            Layout.fillWidth: true

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor

    }

    HoverHandler {
        id: hoverHandler
        cursorShape: Qt.PointingHandCursor
    }
}
