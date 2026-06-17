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

    ///Errors message connection
    Rectangle {
        id: errorToast
        width: errorText.implicitWidth + 40
        height: 40
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height
        color: "#E11D48"
        radius: 8
        z: 100

        Text {
            id: errorText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 14
            font.bold: true
        }

        PropertyAnimation {
            id: showAnimation
            target: errorToast
            property: "y"
            to: window.height - 80
            duration: 300
            easing.type: Easing.OutBack
        }

        PropertyAnimation {
            id: hideAnimation
            target: errorToast
            property: "y"
            to: window.height
            duration: 300
            easing.type: Easing.InBack
        }

        Timer {
            id: toastTimer
            interval: 3000
            onTriggered: hideAnimation.start()
        }

        function showMessage(msg) {
            errorText.text = msg;
            hideAnimation.stop();
            showAnimation.start();
            toastTimer.restart();
        }
    }

    /// Success message connection
        Rectangle {
            id: successToast
            width: successText.implicitWidth + 40
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height // Тоже изначально спрятан внизу
            color: "#10B981" // Приятный зеленый цвет успеха
            radius: 8
            z: 100

            Text {
                id: successText
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 14
                font.bold: true
            }

            PropertyAnimation {
                id: showSuccessAnimation
                target: successToast
                property: "y"
                to: window.height - 80
                duration: 300
                easing.type: Easing.OutBack
            }

            PropertyAnimation {
                id: hideSuccessAnimation
                target: successToast
                property: "y"
                to: window.height
                duration: 300
                easing.type: Easing.InBack
            }

            Timer {
                id: successToastTimer
                interval: 3000
                onTriggered: hideSuccessAnimation.start()
            }

            function showMessage(msg) {
                successText.text = msg;
                hideSuccessAnimation.stop();
                showSuccessAnimation.start();
                successToastTimer.restart();
            }
        }

        // Обновленный блок Connections, который теперь слушает оба события
        Connections {
            target: connManager

            function onErrorOccurred(message) {
                errorToast.showMessage(message);
            }

            function onSuccessOccurred(message) {
                successToast.showMessage(message);
            }
        } ///

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
