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
    height: 700
    color: "#070E16"
    Material.theme: Material.Dark
    minimumWidth: 856

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
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            color: "#0D1520"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 8

                // Text {
                //     text: qsTr("ELM EMULATOR")
                //     color: "white"
                //     font.pixelSize: 18
                //     font.bold: true
                //     Layout.bottomMargin: 20
                //     Layout.leftMargin: 15
                // }

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
                    buttonText: qsTr("Settings")
                    isActive: pageStack.currentIndex === 2
                    onClicked: pageStack.currentIndex = 2
                }

                Item { Layout.fillHeight: true }
            }
        }

        StackLayout {
            id: pageStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0

            OverviewPage {}


        }
    }
}
