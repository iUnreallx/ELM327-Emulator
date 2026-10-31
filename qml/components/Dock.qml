import QtQuick

/// Плавающая навигация внизу: стеклянный tab bar с бегунком + круглая кнопка быстрых действий.
Item {
    id: root

    property var pages: []
    property int currentIndex: 0
    property int logsBadge: 0
    /// [{ id, text, icon, tone }]
    property var fabItems: []
    property bool fabOpen: false
    signal picked(int index)
    signal fabPicked(string id)

    width: bar.width + 12 + fab.width
    height: bar.height

    // ── tab bar ──
    Rectangle { // мягкая тень
        anchors.fill: bar
        anchors.topMargin: 10
        anchors.bottomMargin: -12
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        radius: bar.radius + 4
        color: Theme.dark ? "#70000000" : "#26000000"
    }

    Rectangle {
        id: bar
        width: row.width + 12
        height: 64
        radius: 32
        color: Theme.dark ? Qt.rgba(28 / 255, 28 / 255, 30 / 255, 0.94) : Qt.rgba(1, 1, 1, 0.94)
        border.width: 1
        border.color: Theme.separator
        Behavior on color { ColorAnimation { duration: 300 } }

        Rectangle {
            id: thumb
            y: 6
            height: parent.height - 12
            radius: 26
            color: Theme.fill2
            function itemFor(c, i) { return i >= 0 && i < c ? rep.itemAt(i) : null }
            readonly property var cur: itemFor(rep.count, root.currentIndex)
            x: cur ? 6 + cur.x : 6
            width: cur ? cur.width : 86
            Behavior on x { NumberAnimation { duration: 550; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
        }

        Row {
            id: row
            x: 6
            y: 6

            Repeater {
                id: rep
                model: root.pages
                delegate: Item {
                    id: tab
                    readonly property bool active: root.currentIndex === index
                    width: 86
                    height: 52
                    scale: mouse.pressed ? 0.88 : 1
                    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Icon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: modelData.icon
                            size: 22
                            color: tab.active ? Theme.accentTint : (mouse.containsMouse ? Theme.label : Theme.label2)
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.name
                            font.family: Theme.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: tab.active ? Theme.accentTint : (mouse.containsMouse ? Theme.label : Theme.label2)
                        }
                    }

                    // счётчик непрочитанных
                    Rectangle {
                        visible: modelData.id === "logs"
                        x: parent.width / 2 + 4
                        y: 3
                        height: 16
                        width: Math.max(16, badgeText.implicitWidth + 8)
                        radius: 8
                        color: Theme.red
                        scale: root.logsBadge > 0 ? 1 : 0
                        Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 2 } }
                        Text {
                            id: badgeText
                            anchors.centerIn: parent
                            text: root.logsBadge > 99 ? "99+" : root.logsBadge
                            color: "white"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.picked(index)
                    }
                }
            }
        }
    }

    // ── FAB + меню ──
    Item {
        id: fab
        x: bar.width + 12
        width: 56
        height: 56
        anchors.verticalCenter: bar.verticalCenter

        Rectangle {
            id: btn
            anchors.fill: parent
            radius: width / 2
            color: Theme.accent
            scale: fabMouse.pressed ? 0.9 : 1
            Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }
            Icon {
                anchors.centerIn: parent
                name: "bolt"
                size: 24
                color: Theme.accentFg
                rotation: root.fabOpen ? 90 : 0
                Behavior on rotation { NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.6 } }
            }
            MouseArea {
                id: fabMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.fabOpen = !root.fabOpen
            }
        }

        Column {
            id: menu
            anchors.right: parent.right
            anchors.bottom: parent.top
            anchors.bottomMargin: 18
            spacing: 8
            Repeater {
                model: root.fabItems
                delegate: Rectangle {
                    id: mi
                    readonly property int rev: root.fabItems.length - 1 - index
                    anchors.right: parent.right
                    width: mrow.width + 30
                    height: 46
                    radius: 23
                    color: Theme.dark ? Qt.rgba(44 / 255, 44 / 255, 46 / 255, 0.97) : Qt.rgba(1, 1, 1, 0.97)
                    border.width: 1
                    border.color: Theme.separator
                    opacity: root.fabOpen ? 1 : 0
                    scale: root.fabOpen ? (miMouse.pressed ? 0.95 : 1) : 0.6
                    transformOrigin: Item.Right
                    visible: opacity > 0.01
                    transform: Translate { y: root.fabOpen ? 0 : 16 }
                    Behavior on opacity { SequentialAnimation { PauseAnimation { duration: root.fabOpen ? mi.rev * 40 : 0 } NumberAnimation { duration: 220 } } }
                    Behavior on scale { SequentialAnimation { PauseAnimation { duration: root.fabOpen ? mi.rev * 40 : 0 } NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.6 } } }

                    Row {
                        id: mrow
                        anchors.verticalCenter: parent.verticalCenter
                        x: 8
                        spacing: 10
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 30
                            height: 30
                            radius: 15
                            color: modelData.tone === "acc" ? Theme.accent : Theme[modelData.tone]
                            Icon { anchors.centerIn: parent; name: modelData.icon; size: 16; color: modelData.tone === "acc" ? Theme.accentFg : "white" }
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.text
                            color: Theme.label
                            font.family: Theme.fontFamily
                            font.pixelSize: 15
                            font.weight: Font.Medium
                        }
                    }
                    MouseArea {
                        id: miMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.fabOpen = false; root.fabPicked(modelData.id) }
                    }
                }
            }
        }
    }
}
