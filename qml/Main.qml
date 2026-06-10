import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    id: root
    visible: true
    title: "Elm327 Emulator"
    width: 350
    height: 495
    x: 150
    y: 120
    Material.theme: Material.Dark

    property string currentPage: "MainPage.qml"

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.85
        spacing: 25

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Text {
                text: "Скорость: " + ecuModel.speed + " км/ч"
                color: "white"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignHCenter
            }

            Slider {
                id: speedSlider
                from: 0
                to: 300
                stepSize: 1
                value: ecuModel.speed
                onValueChanged: ecuModel.speed = value
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5

            Text {
                text: "Обороты: " + ecuModel.rpm + " об/мин"
                color: "#41CD52"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignHCenter
            }

            Slider {
                id: rpmSlider
                from: 0
                to: 15000
                stepSize: 50
                value: ecuModel.rpm
                onValueChanged: ecuModel.rpm = value
                Layout.fillWidth: true
            }
        }
    }
}
