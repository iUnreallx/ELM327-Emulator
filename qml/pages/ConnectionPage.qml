import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import "../components"

PageBase {
    id: root

    required property var app
    readonly property bool locked: app.connected

    readonly property real contentW: Math.min(flick.width - Theme.pagePadding * 2, 1320 - Theme.pagePadding * 2)
    readonly property bool wide: contentW > 1100

    scrollY: flick.contentY

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight + 160
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ThemedScrollBar {}

        ColumnLayout {
            id: column
            x: (flick.width - width) / 2
            y: 20
            width: root.contentW
            spacing: Theme.gap

            PageHeader {
                Layout.topMargin: 14
                Layout.bottomMargin: 6
                scroll: flick.contentY
                title: qsTr("Connection")
                subtitle: qsTr("Choose how clients reach the emulator")
            }

            GridLayout {
                Layout.fillWidth: true
                columns: root.wide ? 2 : 1
                columnSpacing: Theme.gap
                rowSpacing: Theme.gap

                // ── транспорт ──
                Panel {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.horizontalStretchFactor: 7
                    Layout.alignment: Qt.AlignTop
                    pop: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 18
                        spacing: 16
                        StatusIcon { on: root.app.connected; tile: 60; iconName: root.app.modeIcons[root.app.connMode] }
                        ColumnLayout {
                            spacing: 1
                            Text {
                                text: root.app.connected ? qsTr("Server is live") : qsTr("Server stopped")
                                color: Theme.label
                                font.family: Theme.fontFamily
                                font.pixelSize: 22
                                font.weight: Font.Bold
                                font.letterSpacing: -0.6
                            }
                            Text {
                                text: (root.app.connected ? qsTr("Listening on ") : qsTr("Will listen on ")) + root.app.endpoint
                                color: Theme.label2
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                            }
                        }
                    }

                    Segmented {
                        Layout.fillWidth: true
                        block: true
                        large: true
                        model: [
                            { text: "Wi-Fi", icon: "wifi" },
                            { text: "Bluetooth", icon: "bt" },
                            { text: "USB / COM", icon: "plug" }
                        ]
                        currentIndex: root.app.connMode
                        onPicked: function (i) {
                            if (root.locked) {
                                root.app.toast(qsTr("Stop the server first"), qsTr("Connection type can only change while stopped"), "red", "x")
                                return
                            }
                            root.app.connMode = i
                            if (i !== 0) root.app.refreshPorts()
                        }
                    }

                    // Wi-Fi: IP + порт
                    RowLayout {
                        visible: root.app.connMode === 0
                        Layout.fillWidth: true
                        Layout.topMargin: 18
                        spacing: 12
                        FloatField {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 2
                            label: qsTr("IP address")
                            text: root.app.ip
                            locked: root.locked
                            onEdited: function (t) { root.app.ip = t }
                        }
                        FloatField {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            label: qsTr("Port")
                            text: root.app.port
                            locked: root.locked
                            hints: Qt.ImhDigitsOnly
                            onEdited: function (t) { root.app.port = t }
                        }
                    }

                    // Bluetooth / USB: COM-порт
                    RowLayout {
                        visible: root.app.connMode !== 0
                        Layout.fillWidth: true
                        Layout.topMargin: 18
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 58
                            radius: 14
                            color: portMouse.containsMouse ? Theme.fill2 : Theme.fill
                            opacity: root.locked ? 0.5 : 1
                            Behavior on color { ColorAnimation { duration: 150 } }
                            Column {
                                x: 16
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: root.app.connMode === 1 ? qsTr("Bluetooth port") : qsTr("COM port")
                                    color: Theme.label2
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: root.app.com !== "" ? root.app.com : qsTr("None")
                                    color: Theme.label
                                    font.family: Theme.monoFamily
                                    font.pixelSize: 17
                                }
                            }
                            Icon { anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; name: "chevD"; size: 18; color: Theme.label3 }
                            MouseArea {
                                id: portMouse
                                anchors.fill: parent
                                enabled: !root.locked
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: { root.app.refreshPorts(); root.app.portsRequested() }
                            }
                        }
                        RoundButton {
                            diameter: 58
                            iconName: "reset"
                            onClicked: {
                                root.app.refreshPorts()
                                root.app.toast(qsTr("Ports refreshed"), qsTr("%1 found").arg(root.app.ports.length), "blue", "reset")
                            }
                        }
                    }

                    SlideConfirm {
                        Layout.fillWidth: true
                        Layout.topMargin: 22
                        tone: root.app.connected ? Theme.red : Theme.green
                        iconName: root.app.connected ? "stop" : "power"
                        text: root.app.connected ? qsTr("Slide to stop the server") : qsTr("Slide to start the server")
                        onConfirmed: root.app.toggleConnection()
                    }
                }

                // ── адаптер + сессия ──
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.horizontalStretchFactor: 5
                    Layout.alignment: Qt.AlignTop
                    spacing: Theme.gap

                    // карточка адаптера: наклоняется за курсором
                    Rectangle {
                        id: tilt
                        Layout.fillWidth: true
                        Layout.preferredHeight: 210
                        radius: 24
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#1f1f22" }
                            GradientStop { position: 1.0; color: "#0b0b0d" }
                        }
                        border.width: 1
                        border.color: "#14ffffff"
                        antialiasing: true

                        property real rx: 0
                        property real ry: 0
                        transform: [
                            Rotation { origin.x: tilt.width / 2; origin.y: tilt.height / 2; axis { x: 0; y: 1; z: 0 } angle: tilt.ry },
                            Rotation { origin.x: tilt.width / 2; origin.y: tilt.height / 2; axis { x: 1; y: 0; z: 0 } angle: tilt.rx }
                        ]
                        Behavior on rx { NumberAnimation { duration: 450; easing.type: Easing.OutBack } }
                        Behavior on ry { NumberAnimation { duration: 450; easing.type: Easing.OutBack } }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onPositionChanged: function (m) {
                                tilt.ry = (m.x / tilt.width - 0.5) * 14
                                tilt.rx = -(m.y / tilt.height - 0.5) * 14
                            }
                            onExited: { tilt.rx = 0; tilt.ry = 0 }
                        }

                        Row {
                            x: 20
                            y: 18
                            spacing: 8
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 9; height: 9; radius: 5
                                color: root.app.connected ? Theme.green : "#8e8e93"
                                border.width: root.app.connected ? 4 : 0
                                border.color: Theme.tint(Theme.green, 0.22)
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.app.connected ? qsTr("Connected") : qsTr("Idle")
                                color: "white"
                                font.family: Theme.fontFamily
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                            }
                        }
                        Icon { anchors.right: parent.right; anchors.rightMargin: 24; anchors.verticalCenter: parent.verticalCenter; name: "plug"; size: 92; color: "#21ffffff" }
                        Column {
                            x: 20
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 18
                            Text {
                                text: "ELM327 V1.5"
                                color: "#99ffffff"
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                font.letterSpacing: 0.8
                            }
                            Text {
                                text: root.app.endpoint
                                color: "white"
                                font.family: Theme.monoFamily
                                font.pixelSize: 24
                                font.weight: Font.ExtraBold
                            }
                        }
                    }

                    Panel {
                        Layout.fillWidth: true
                        pop: 2

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.bottomMargin: 14
                            Text { text: qsTr("Session"); color: Theme.label; font.family: Theme.fontFamily; font.pixelSize: 17; font.weight: Font.DemiBold }
                            Item { Layout.fillWidth: true }
                            AppButton {
                                size: "sm"
                                kind: "tinted"
                                text: qsTr("Copy address")
                                trailingIcon: "copy"
                                onClicked: {
                                    clip.text = root.app.endpoint
                                    clip.selectAll()
                                    clip.copy()
                                    root.app.toast(qsTr("Address copied"), root.app.endpoint, "blue", "copy")
                                }
                            }
                        }
                        TextEdit { id: clip; visible: false }

                        Group {
                            Layout.fillWidth: true
                            Cell { first: true; title: qsTr("Protocol"); valueText: "ISO 15765-4 (CAN)" }
                            Cell { title: qsTr("Clients"); valueText: root.app.connected ? "1" : "0" }
                            Cell { title: qsTr("Uptime"); valueText: root.app.formatUptime(root.app.uptime) }
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.topMargin: 12
                            text: qsTr("Point your OBD app at the address above. The adapter answers AT commands and PIDs with the delays you set.")
                                  + (root.locked ? "  " + qsTr("Stop the server to change these settings.") : "")
                            color: Theme.label2
                            font.family: Theme.fontFamily
                            font.pixelSize: 13
                            lineHeight: 1.15
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
}
