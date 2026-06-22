import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
Rectangle {
    id: root
    color: "#0B1120"
    border.color: "#1E293B"
    border.width: 1
    radius: 12
    Layout.preferredHeight: 180
    clip: true

    property int txCount: 0
    property int rxCount: 0
    property int uptimeSeconds: 0
    property bool autoScroll: true

    FileDialog {
        id: exportDialog
        title: "Export Logs"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Text files (*.txt)", "All files (*)"]
        defaultSuffix: "txt"
        onAccepted: {
            logManager.exportLogs(selectedFile.toString())
        }
    }

    Timer {
        interval: 1000
        running: connManager.isConnected
        repeat: true
        onTriggered: root.uptimeSeconds++
    }

    Connections {
        target: connManager
        function onConnectionChanged(isConnected) {
            if (!isConnected) root.uptimeSeconds = 0;
        }
    }

    function formatUptime(secs) {
        let h = Math.floor(secs / 3600).toString().padStart(2, '0');
        let m = Math.floor((secs % 3600) / 60).toString().padStart(2, '0');
        let s = (secs % 60).toString().padStart(2, '0');
        return h + ":" + m + ":" + s;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        /// шапка ( логи + кнопки )
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: "transparent"

            Rectangle { // Нижняя граница хедера
                width: parent.width; height: 1
                color: "#1E293B"; anchors.bottom: parent.bottom
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Text {
                    text: qsTr("LOGS")
                    color: "#94A3B8"
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 2
                }

                Item { Layout.fillWidth: true }

                /// pause
                RowLayout {
                    spacing: 5
                    Layout.alignment: Qt.AlignVCenter

                    HoverHandler { id: hoverPause; cursorShape: Qt.PointingHandCursor }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: logManager.isLogPaused = !logManager.isLogPaused
                    }

                    IconImage {
                        source: logManager.isLogPaused ? "../assets/logsPanel/play.svg" : "../assets/logsPanel/pause.svg"
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        sourceSize: Qt.size(20, 20)
                        fillMode: Image.PreserveAspectFit
                        opacity: hoverPause.hovered ? 1.0 : 0.7
                        color: hoverPause.hovered ? "#FFFFFF" : "#38BDF8"
                    }

                    Text { text: logManager.isLogPaused ? qsTr("Resume") : qsTr("Pause"); color: hoverPause.hovered ? "#FFFFFF" : "#38BDF8"; font.pixelSize: 12; font.bold: true }
                }

                Item { width: 10 }

                /// cls logs
                RowLayout {
                    spacing: 5
                    HoverHandler { id: hoverClear; cursorShape: Qt.PointingHandCursor }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: logManager.clearLogs()
                    }

                    IconImage  {
                        source: "../assets/logsPanel/clear.svg"
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        sourceSize: Qt.size(20, 20)
                        fillMode: Image.PreserveAspectFit
                        opacity: hoverClear.hovered ? 1.0 : 0.7
                        color: hoverClear.hovered ? "#FFFFFF" : "#38BDF8"
                    }

                    Text { text: qsTr("Clear"); color: hoverClear.hovered ? "#FFFFFF" : "#38BDF8"; font.pixelSize: 12; font.bold: true }
                }

                Item { width: 10 }

                /// exports
                RowLayout {
                    spacing: 5
                    HoverHandler { id: hoverExport; cursorShape: Qt.PointingHandCursor }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: exportDialog.open()
                    }

                    IconImage  {
                        source: "../assets/logsPanel/export.svg"
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        sourceSize: Qt.size(20, 20)
                        fillMode: Image.PreserveAspectFit
                        opacity: hoverExport.hovered ? 1.0 : 0.7
                        color: hoverExport.hovered ? "#FFFFFF" : "#38BDF8"
                    }

                    Text { text: qsTr("Export"); color: hoverExport.hovered ? "#FFFFFF" : "#38BDF8"; font.pixelSize: 12; font.bold: true }
                }
            }
        }

        // ================= LIST VIEW =================
        ListModel { id: logModel }

        Connections {
            target: logManager
            function onLogsAdded(isRx, msg, timestamp) {
                logModel.append({ "isRx": isRx, "msg": msg, "timestamp": timestamp })
                if (isRx) root.rxCount++;
                    else root.txCount++;
                if (root.autoScroll)
                    listView.positionViewAtEnd();
            }
            function onLogsCleared() {
                logModel.clear()
                root.rxCount = 0
                root.txCount = 0
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 10
            clip: true
            model: logModel
            spacing: 8

            // Если юзер крутит колесико вверх — отключаем автоскролл
            onContentYChanged: {
                if (contentY < contentHeight - height - 20) {
                    root.autoScroll = false;
                } else {
                    root.autoScroll = true;
                }
            }

            delegate: RowLayout {
                width: listView.width
                spacing: 20

                Text {
                    text: model.timestamp
                    color: "#64748B"
                    font.pixelSize: 13
                    Layout.preferredWidth: 72
                }

                Text {
                    text: model.isRx ? "←" : "→"
                    color: "#64748B"
                    font.pixelSize: 20
                    font.bold: true
                }

                Text {
                    text: model.isRx ? "RX" : "TX"
                    color: model.isRx ? "#BCED40" : "#FFFFFF"
                    font.pixelSize: 13
                    font.bold: true
                    Layout.preferredWidth: 25
                }

                Text {
                    text: model.msg
                    color: "#E2E8F0"
                    font.pixelSize: 13
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAnywhere
                }
            }

            Text {
                text: qsTr("Logs not found")
                color: "#64748B"
                font.pixelSize: 12
                font.letterSpacing: 1.5
                anchors.leftMargin: 14
                visible: logModel.count === 0
            }

            ScrollBar.vertical: ScrollBar {
                active: true
                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: 3
                    color: parent.pressed ? "#475569" : "#334155"
                }
            }
        }

        // ================= FOOTER =================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: "transparent"

            Rectangle { // Верхняя граница футера
                width: parent.width; height: 1
                color: "#1E293B"; anchors.top: parent.top
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                Text {
                    text: "Uptime: " + root.formatUptime(root.uptimeSeconds)
                    color: "#64748B"
                    font.pixelSize: 11
                }

                Item { Layout.fillWidth: true } // Spacer

                Text {
                    text: `Packets (TX/RX): ${root.txCount} / ${root.rxCount}`
                    color: "#64748B"
                    font.pixelSize: 11
                }

                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: logManager.isConnected ? (logManager.isLogPaused ? "#EAB308" : "#10B981") : "#F44336"
                }
            }
        }
    }
}
