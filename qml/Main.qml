import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import "components"
import "pages"

ApplicationWindow {
    id: window
    visible: true
    title: "Elm327 Emulator"
    width: 1100
    height: 650
    color: "#070E16"
    Material.theme: Material.Dark
    minimumWidth: 818
    minimumHeight: 447

    onHeightChanged: {
        console.log( window.height)
    }

    ToastNotification {
        id: globalToast
    }

    Connections {
        target: connManager

        function onErrorOccurred(message) {
            globalToast.show(message, true);
        }

        function onSuccessOccurred(message) {
            globalToast.show(message, false);
        }
    }

    Connections {
        target: logManager

        function onErrorOccurred(message) {
            globalToast.show(message, true);
        }

        function onSuccessOccurred(message) {
            globalToast.show(message, false);
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 180
            Layout.fillHeight: true
            color: "#0D1520"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 0

                    IconImage {
                        source: "assets/sidebar/logo.png"
                        sourceSize: Qt.size(52, 52)
                        // color: "#38BDF8"
                        Layout.alignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: "Elm"
                            color: "white"
                            font.pixelSize: 20
                            font.bold: true
                            font.family: "Ubuntu-Bold"
                            font.letterSpacing: 1.9
                        }

                        Text {
                            text: "EMULATOR"
                            color: "#38BDF8"
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 2.5
                        }
                    }
                }

                SidebarButton {
                    buttonText: qsTr("Overview")
                    isActive: pageStack.currentIndex === 0
                    onClicked: pageStack.currentIndex = 0
                }

                SidebarButton {
                    buttonText: qsTr("Connection")
                    isActive: pageStack.currentIndex === 1
                    onClicked: pageStack.currentIndex = 1
                }

                SidebarButton {
                    buttonText: qsTr("Cards")
                    isActive: pageStack.currentIndex === 2
                    onClicked: pageStack.currentIndex = 2
                }

                SidebarButton {
                    buttonText: qsTr("Logs")
                    isActive: pageStack.currentIndex === 3
                    onClicked: pageStack.currentIndex = 3
                }

                SidebarButton {
                    buttonText: qsTr("Delay")
                    isActive: pageStack.currentIndex === 4
                    onClicked: pageStack.currentIndex = 4
                }

                // SidebarButton {
                //     buttonText: qsTr("DTC")
                //     isActive: pageStack.currentIndex === 4
                //     onClicked: pageStack.currentIndex = 4
                // }



                // SidebarButton {
                //     buttonText: qsTr("Settings")
                //     isActive: pageStack.currentIndex === 6
                //     onClicked: pageStack.currentIndex = 6
                // }

                Item { Layout.fillHeight: true }
            }
        }

        StackLayout {
            id: pageStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0

            OverviewPage {}

            ConnectionPage {}

            CardsPage {}

            LogsPage {}

            DelayPage {}

        }
    }
}
