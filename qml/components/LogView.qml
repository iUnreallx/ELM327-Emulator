import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

/// Список трафика RX/TX. Строку можно потянуть влево: Pin / Copy.
Item {
    id: root

    required property var app
    property string filter: "ALL"      // ALL | RX | TX
    property string query: ""
    property bool autoScroll: true
    property bool interactive: true
    property int rowHeight: 46
    property int matchCount: 0
    property int openIndex: -1

    function scrollToEnd() { list.positionViewAtEnd() }

    function recount() {
        var q = query.toLowerCase()
        var n = 0
        var m = app.logModel
        for (var i = 0; i < m.count; ++i) {
            var it = m.get(i)
            var okDir = filter === "ALL" || (filter === "RX") === it.isRx
            var okQ = q === "" || (it.msg + " " + it.decoded).toLowerCase().indexOf(q) >= 0
            if (okDir && okQ) n++
        }
        matchCount = n
    }

    onFilterChanged: recount()
    onQueryChanged: recount()
    Component.onCompleted: recount()

    Connections {
        target: root.app.logModel
        function onCountChanged() { root.recount() }
    }

    ListView {
        id: list
        anchors.fill: parent
        clip: true
        model: root.app.logModel
        interactive: root.interactive
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ThemedScrollBar { visible: root.interactive }

        onCountChanged: {
            if (root.autoScroll) Qt.callLater(list.positionViewAtEnd)
        }
        onMovementStarted: root.openIndex = -1

        add: Transition {
            ParallelAnimation {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 350 }
                NumberAnimation { property: "y"; from: 10; duration: 550; easing.type: Easing.OutBack; easing.overshoot: 1.4 }
            }
        }

        delegate: Item {
            id: row
            readonly property bool matches:
                (root.filter === "ALL" || (root.filter === "RX") === model.isRx)
                && (root.query === ""
                    || (model.msg + " " + model.decoded).toLowerCase().indexOf(root.query.toLowerCase()) >= 0)
            readonly property bool pinned: model.pinned === true
            readonly property bool isOpen: root.openIndex === index

            width: list.width
            height: matches ? root.rowHeight : 0
            visible: matches
            clip: true

            onIsOpenChanged: if (!isOpen && face.x < 0) face.x = 0

            // действия под строкой
            Row {
                anchors.right: parent.right
                height: parent.height
                visible: face.x < -2
                Rectangle {
                    width: 84; height: parent.height
                    color: Theme.orange
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Icon { anchors.horizontalCenter: parent.horizontalCenter; name: "pin"; size: 17; color: "white" }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: row.pinned ? qsTr("Unpin") : qsTr("Pin"); color: "white"; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.app.logModel.setProperty(index, "pinned", !row.pinned)
                            root.app.toast(row.pinned ? qsTr("Pinned") : qsTr("Unpinned"), model.msg, "orange", "pin")
                            root.openIndex = -1
                        }
                    }
                }
                Rectangle {
                    width: 84; height: parent.height
                    color: Theme.blue
                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Icon { anchors.horizontalCenter: parent.horizontalCenter; name: "copy"; size: 17; color: "white" }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("Copy"); color: "white"; font.family: Theme.fontFamily; font.pixelSize: 11; font.weight: Font.DemiBold }
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            clip.text = model.msg
                            clip.selectAll()
                            clip.copy()
                            root.app.toast(qsTr("Copied"), model.msg, "blue", "copy")
                            root.openIndex = -1
                        }
                    }
                }
            }

            // лицевая часть
            Rectangle {
                id: face
                width: parent.width
                height: parent.height
                x: 0
                color: row.pinned ? Qt.tint(Theme.surface, Theme.tint(Theme.orange, 0.09))
                                  : (faceMouse.containsMouse ? Qt.tint(Theme.surface, Theme.fill) : Theme.surface)
                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on x { enabled: !faceMouse.drag.active; NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }

                Rectangle { // разделитель
                    x: 20
                    width: parent.width - 20
                    height: 1
                    color: Theme.separator
                    opacity: 0.6
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 12

                    Text {
                        Layout.preferredWidth: 104
                        text: model.timestamp
                        color: Theme.label3
                        font.family: Theme.monoFamily
                        font.pixelSize: 13
                    }
                    Badge {
                        Layout.preferredWidth: 44
                        implicitHeight: 22
                        text: model.isRx ? "RX" : "TX"
                        tone: model.isErr ? "red" : (model.isRx ? "green" : "gray")
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        Layout.horizontalStretchFactor: 8
                        text: model.msg
                        color: model.isErr ? Theme.red : Theme.label
                        font.family: Theme.monoFamily
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 0
                        Layout.horizontalStretchFactor: 12
                        text: model.decoded
                        color: model.isErr ? Theme.red : Theme.label2
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        elide: Text.ElideRight
                    }
                    Icon {
                        Layout.preferredWidth: 18
                        name: "pin"
                        size: 15
                        color: Theme.orange
                        opacity: row.pinned ? 1 : 0
                        scale: row.pinned ? 1 : 0.4
                        Behavior on opacity { NumberAnimation { duration: 250 } }
                        Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 2 } }
                    }
                }

                MouseArea {
                    id: faceMouse
                    anchors.fill: parent
                    enabled: root.interactive
                    hoverEnabled: true
                    drag.target: face
                    drag.axis: Drag.XAxis
                    drag.minimumX: -208
                    drag.maximumX: 30
                    onPressed: if (root.openIndex !== index) root.openIndex = -1
                    onReleased: {
                        if (face.x < -60) { face.x = -168; root.openIndex = index }
                        else { face.x = 0; if (root.openIndex === index) root.openIndex = -1 }
                    }
                }
            }
        }
    }

    // пустое состояние
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8
        visible: root.matchCount === 0

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 68
            Layout.preferredHeight: 68
            radius: 22
            color: Theme.fill
            Icon { anchors.centerIn: parent; name: "terminal"; size: 30; color: Theme.label3 }
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 6
            text: qsTr("No traffic yet")
            color: Theme.label
            font.family: Theme.fontFamily
            font.pixelSize: 17
            font.weight: Font.DemiBold
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.app.connected ? qsTr("Waiting for a client to send a request…")
                                     : qsTr("Start the server and connect an OBD app.")
            color: Theme.label2
            font.family: Theme.fontFamily
            font.pixelSize: 14
        }
    }

    TextEdit { id: clip; visible: false }
}
