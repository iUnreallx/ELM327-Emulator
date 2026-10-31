import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Dialogs
import "../components"

PageBase {
    id: root

    required property var app
    property string filter: "ALL"
    property bool autoScroll: true

    readonly property real contentW: Math.min(width - Theme.pagePadding * 2, 1320 - Theme.pagePadding * 2)

    scrollY: 0

    function exportLogs() { exportDialog.open() }
    function clearWithConfirm() {
        app.confirmRequested(qsTr("Clear all logs?"),
                             qsTr("This removes every captured request and response."),
                             qsTr("Clear"), true,
                             function () {
                                 logManager.clearLogs()
                                 app.toast(qsTr("Logs cleared"), "", "gray", "trash")
                             })
    }

    FileDialog {
        id: exportDialog
        title: qsTr("Export Logs")
        fileMode: FileDialog.SaveFile
        nameFilters: ["Text files (*.txt)", "All files (*)"]
        defaultSuffix: "txt"
        onAccepted: {
            logManager.exportLogs(selectedFile.toString())
            root.app.toast(qsTr("Logs exported"), "", "green", "download")
        }
    }

    ColumnLayout {
        x: (root.width - width) / 2
        y: 20
        width: root.contentW
        height: root.height - 20 - 112
        spacing: Theme.gap

        PageHeader {
            Layout.topMargin: 14
            Layout.bottomMargin: 0
            title: qsTr("Logs")
            subtitle: qsTr("Every request and response, in real time")
        }

        Panel {
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 0
            clip: true
            pop: 0

            // панель инструментов
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 22
                Layout.topMargin: 18
                Layout.bottomMargin: 14
                spacing: 14

                Segmented {
                    model: ["ALL", "RX", "TX"]
                    currentIndex: ["ALL", "RX", "TX"].indexOf(root.filter)
                    onPicked: function (i) { root.filter = ["ALL", "RX", "TX"][i] }
                }
                SearchField {
                    id: search
                    Layout.preferredWidth: 260
                    placeholder: qsTr("Search logs")
                }
                RowLayout {
                    spacing: 10
                    Layout.leftMargin: 6
                    IosSwitch {
                        small: true
                        checked: root.autoScroll
                        onToggled: function (c) {
                            root.autoScroll = c
                            if (c) logView.scrollToEnd()
                        }
                    }
                    Text {
                        text: qsTr("Auto-scroll")
                        color: Theme.label2
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                    }
                }
                Item { Layout.fillWidth: true }
                AppButton {
                    size: "sm"
                    iconName: logManager.isLogPaused ? "play" : "pause"
                    text: logManager.isLogPaused ? qsTr("Resume") : qsTr("Pause")
                    onClicked: {
                        logManager.isLogPaused = !logManager.isLogPaused
                        root.app.toast(logManager.isLogPaused ? qsTr("Logging paused") : qsTr("Logging resumed"), "", "acc",
                                       logManager.isLogPaused ? "pause" : "play")
                    }
                }
                AppButton {
                    size: "sm"
                    kind: "danger"
                    iconName: "trash"
                    text: qsTr("Clear")
                    onClicked: root.clearWithConfirm()
                }
                AppButton {
                    size: "sm"
                    kind: "tinted"
                    iconName: "download"
                    text: qsTr("Export")
                    onClicked: exportDialog.open()
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.separator; opacity: 0.6 }
            Text {
                Layout.leftMargin: 22
                Layout.topMargin: 8
                Layout.bottomMargin: 6
                text: qsTr("Swipe a row to the left to pin or copy it.")
                color: Theme.label3
                font.family: Theme.fontFamily
                font.pixelSize: 13
            }

            LogView {
                id: logView
                Layout.fillWidth: true
                Layout.fillHeight: true
                app: root.app
                filter: root.filter
                query: search.text
                autoScroll: root.autoScroll
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.separator; opacity: 0.6 }

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 22
                Layout.topMargin: 12
                Layout.bottomMargin: 12

                Text {
                    text: qsTr("Uptime  ") + root.app.formatUptime(root.app.uptime)
                    color: Theme.label2
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: qsTr("Packets (TX/RX)  ") + root.app.txCount + " / " + root.app.rxCount
                    color: Theme.label2
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                }
            }
        }
    }
}
