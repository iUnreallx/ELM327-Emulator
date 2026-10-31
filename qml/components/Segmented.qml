import QtQuick

/// Сегмент-переключатель со скользящим бегунком.
/// model: ["ALL", "RX"] или [{ text: "Wi-Fi", icon: "wifi" }]; currentIndex = -1 — ничего не выбрано.
Rectangle {
    id: root

    property var model: []
    property int currentIndex: -1
    property bool block: false
    property bool large: false
    signal picked(int index)

    readonly property int itemHeight: large ? 40 : 32
    readonly property int count: model.length

    implicitHeight: itemHeight + 4
    implicitWidth: row.implicitWidth + 4
    radius: 10
    color: Theme.fill

    function itemFor(c, i) { return i >= 0 && i < c ? rep.itemAt(i) : null }
    readonly property var currentItem: itemFor(rep.count, currentIndex)

    Rectangle { // бегунок
        id: thumb
        y: 2
        height: root.itemHeight
        radius: 8
        color: Theme.dark ? "#636366" : "#ffffff"
        opacity: root.currentItem ? 1 : 0
        x: root.currentItem ? row.x + root.currentItem.x : 0
        width: root.currentItem ? root.currentItem.width : 0
        Behavior on x { NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
        Behavior on width { NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    Row {
        id: row
        x: 2
        y: 2

        Repeater {
            id: rep
            model: root.model
            delegate: Item {
                id: seg
                readonly property bool active: root.currentIndex === index
                readonly property string label: typeof modelData === "string" ? modelData : modelData.text
                readonly property string iconName: typeof modelData === "string" ? "" : (modelData.icon || "")

                width: root.block ? (root.width - 4) / root.count : content.implicitWidth + 32
                height: root.itemHeight
                opacity: !active && mouse.containsMouse ? 0.65 : 1

                Row {
                    id: content
                    anchors.centerIn: parent
                    spacing: 7
                    Icon {
                        visible: seg.iconName !== ""
                        anchors.verticalCenter: parent.verticalCenter
                        name: seg.iconName
                        size: 17
                        color: seg.active ? Theme.label : Theme.label2
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: seg.label
                        color: Theme.label
                        font.family: Theme.fontFamily
                        font.pixelSize: root.large ? 15 : 14
                        font.weight: seg.active ? Font.DemiBold : Font.Medium
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
