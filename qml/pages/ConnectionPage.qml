import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    // 0 - WIFI, 1 - Bluetooth, 2 - USB
    property int activeMode: 0

    property bool isConnected: connManager.isConnected
    property string statusText: isConnected ? qsTr("Emulator is ready.")
                                            : qsTr("Waiting for connection...")

    Layout.fillWidth: true
    Layout.preferredHeight: 180
    color: "#0B1120"
    border.color: "#1E293B"
    border.width: 1
    radius: 12
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 15

        Text {
            text: qsTr("CONNECTION")
            color: "#94A3B8"
            font.pixelSize: 12
            font.bold: true
            font.letterSpacing: 2
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            /// правая часть ( выбор ком порта или ip )
            RowLayout {
                id: rightPanel
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 30

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: "#1E293B"
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignTop
                    spacing: 20

                    StackLayout {
                        currentIndex: activeMode === 0 ? 0 : 1

                        RowLayout {
                            spacing: 40

                            ColumnLayout {
                                Text { text: qsTr("IP ADDRESS"); color: "#64748B"; font.pixelSize: 10; font.bold: true }
                                TextField {
                                    id: ipField
                                    text: "192.168.1.50"
                                    color: "white"
                                    font.pixelSize: 14
                                    verticalAlignment: TextInput.AlignVCenter

                                    validator: RegularExpressionValidator {
                                        /// Отбрасывает буквы + цифры более одного байта - 255
                                        regularExpression: /^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){0,3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)?$/
                                    }
                                    onTextEdited: {
                                        let parts = text.split('.');
                                        let lastPart = parts[parts.length - 1];
                                        if (lastPart.length === 3 && parts.length < 4) {
                                            text = text + ".";
                                            cursorPosition = text.length;
                                        }
                                    }
                                    background: Rectangle {
                                        color: "#1E293B"
                                        radius: 4
                                        implicitHeight: 30
                                        implicitWidth: 150
                                    }
                                }
                            }

                            ColumnLayout {
                                Text { text: qsTr("PORT"); color: "#64748B"; font.pixelSize: 10; font.bold: true }
                                TextField {
                                    id: portField
                                    text: "35000"
                                    color: "white"
                                    verticalAlignment: TextInput.AlignVCenter
                                    font.pixelSize: 14
                                    maximumLength: 5
                                    validator: IntValidator {
                                        bottom: 1
                                        top: 65535
                                    }
                                    background: Rectangle { color: "#1E293B"; radius: 4; implicitHeight: 30; implicitWidth: 100 }
                                }
                            }
                        }

                        /// управление com портами
                        RowLayout {
                            ColumnLayout {
                                Text { text: qsTr("COM PORT"); color: "#64748B"; font.pixelSize: 10; font.bold: true }

                                ComboBox {
                                    id: comField
                                    editable: true
                                    model: []

                                    onDownChanged: {
                                        if (down) {
                                            comField.model = connManager.getAvailablePorts();
                                        }
                                    }

                                    Component.onCompleted: {
                                        editText = "COM6"
                                    }

                                    background: Rectangle {
                                        color: "#1E293B"
                                        radius: 4
                                        implicitHeight: 30
                                        implicitWidth: 290
                                    }

                                    contentItem: Item {
                                        TextInput {
                                            anchors.left: parent.left
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom
                                            anchors.right: parent.right
                                            anchors.rightMargin: 40
                                            anchors.leftMargin: 5
                                            verticalAlignment: Text.AlignVCenter
                                            text: comField.editText
                                            color: "white"
                                            font.pixelSize: 14
                                            selectionColor: "#38BDF8"
                                            selectedTextColor: "#0B1120"
                                            selectByMouse: true
                                            autoScroll: true
                                            onTextEdited: comField.editText = text
                                        }
                                    }

                                    indicator: Text {
                                        x: comField.width - width - 15
                                        y: comField.topPadding + (comField.availableHeight - height) / 2
                                        text: "▼"
                                        color: comField.popup.opened ? "#38BDF8" : "#94A3B8"
                                        font.pixelSize: 12
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    delegate: ItemDelegate {
                                        width: comField.width
                                        contentItem: Text {
                                            text: modelData
                                            color: "white"
                                            font.pixelSize: 14
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        background: Rectangle {
                                            color: hovered ? "#2D3748" : "#1E293B"
                                        }
                                    }

                                    popup: Popup {
                                        y: comField.height - 1
                                        width: comField.width
                                        implicitHeight: contentItem.implicitHeight
                                        padding: 1
                                        contentItem: ListView {
                                            clip: true
                                            implicitHeight: contentHeight
                                            model: comField.popup.visible ? comField.delegateModel : null
                                            currentIndex: comField.highlightedIndex
                                        }
                                        background: Rectangle {
                                            color: "#1E293B"
                                            border.color: "#0B1120"
                                            radius: 4
                                        }
                                    }

                                    MouseArea {
                                        anchors.right: parent.right
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: 40
                                        z: 99

                                        cursorShape: Qt.PointingHandCursor
                                        acceptedButtons: Qt.NoButton
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        spacing: 40

                        ColumnLayout {
                            Text { text: qsTr("PROTOCOL"); color: "#64748B"; font.pixelSize: 10; font.bold: true }
                            Text { text: "ISO 15765-4 (CAN 11/500)"; color: "white"; font.pixelSize: 14 }
                        }

                        ColumnLayout {
                            Text { text: qsTr("ADAPTER"); color: "#64748B"; font.pixelSize: 10; font.bold: true }
                            Text { text: "ELM327 v1.5"; color: "white"; font.pixelSize: 14 }
                        }
                    }
                }
            }

            /// выбор типа подключения
            ColumnLayout {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: rightPanel.left
                anchors.rightMargin: 40
                spacing: 5

                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: "transparent"
                    border.color: "#1E293B"
                    radius: 6

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        /// wifi
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: activeMode === 0 ? "#1E293B" : "transparent"
                            radius: 6

                            Text {
                                anchors.centerIn: parent
                                text: "Wi-Fi"
                                color: activeMode === 0 ? "#38BDF8" : "#94A3B8"
                                font.bold: activeMode === 0
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: activeMode = 0
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        /// Bluetooth
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: activeMode === 1 ? "#1E293B" : "transparent"
                            radius: 6

                            Text {
                                anchors.centerIn: parent
                                text: "Bluetooth"
                                color: activeMode === 1 ? "#38BDF8" : "#94A3B8"
                                font.bold: activeMode === 1
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: activeMode = 1
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        /// USB
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: activeMode === 2 ? "#1E293B" : "transparent"
                            radius: 6

                            Text {
                                anchors.centerIn: parent
                                text: "USB"
                                color: activeMode === 2 ? "#38BDF8" : "#94A3B8"
                                font.bold: activeMode === 2
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: activeMode = 2
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }

                /// status & action block
                ColumnLayout {
                    id: statusBlock
                    spacing: 4
                    Layout.fillWidth: true
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter

                        ColumnLayout {
                            spacing: 0
                            Layout.alignment: Qt.AlignVCenter

                            RowLayout {
                                spacing: 6
                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: isConnected ? "#41CD52" : "#F44336"
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    text: isConnected ? qsTr("Connected") : qsTr("Disconnected")
                                    color: isConnected ? "#41CD52" : "#F44336"
                                    font.bold: true
                                    font.pixelSize: 13
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            Text {
                                text: root.statusText
                                color: "#94A3B8"
                                font.pixelSize: 12
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        IconImage {
                            id: infoIcon
                            source: "../assets/connectionPanel/info.svg"
                            Layout.preferredWidth: 14
                            Layout.preferredHeight: 14
                            sourceSize: Qt.size(14, 14)
                            color: hoverInfo.hovered ? "#FFFFFF" : "#64748B"
                            Layout.alignment: Qt.AlignVCenter

                            Behavior on color { ColorAnimation { duration: 150 } }

                            HoverHandler {
                                id: hoverInfo
                                cursorShape: Qt.PointingHandCursor
                            }

                            ToolTip {
                                id: infoToolTip
                                visible: hoverInfo.hovered
                                delay: 300
                                text: {
                                    if (root.activeMode === 0) {
                                        return qsTr("Wi-Fi (TCP): Эмулирует точку доступа. Клиент подключается по IP и порту 35000.");
                                    } else if (root.activeMode === 1) {
                                        return qsTr("Bluetooth: Включите bluetooth на устройстве, и выберите свободный com-port.\nПосле этого сопрягите устройство с obd2 приложением.");
                                    } else {
                                        return qsTr("USB (COM): Подключите кабель к устройству и выберите созданный последовательный порт.\nПрямое serial-соединение на скорости 38400 бод.");
                                    }
                                }

                                background: Rectangle {
                                    color: "#0F172A"
                                    border.color: "#334155"
                                    border.width: 1
                                    radius: 6
                                }
                                contentItem: Text {
                                    text: infoToolTip.text
                                    color: "#E2E8F0"
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignHCenter
                                            // Настройка межстрочного интервала (если захочется сделать еще плотнее)
                                            // lineHeight: 1.1
                                    font.family: "Ubuntu-Regular"
                                }
                            }
                        }
                    }

                    Item {
                        Layout.preferredHeight: 0
                    }

                    /// КНОПКА START / STOP SERVER
                    Rectangle {
                        id: actionButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        radius: 6
                        color: isConnected ? "#E11D48" : "#10B981"

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                                easing.type: Easing.InOutQuad
                            }
                        }

                        transformOrigin: Item.Center
                        scale: startMouseArea.pressed ? 0.96 : 1.0

                        Behavior on scale {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.OutQuad
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: isConnected ? qsTr("STOP SERVER") : qsTr("START SERVER")
                            color: "#FFFFFF"
                            font.bold: true
                            font.pixelSize: 12
                            font.letterSpacing: 1
                        }

                        MouseArea {
                            id: startMouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                connManager.toggleConnection(activeMode, ipField.text, portField.text, comField.editText)
                            }
                        }
                    }
                }
            }
        }
    }
}
