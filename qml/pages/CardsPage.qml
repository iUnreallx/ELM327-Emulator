import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "../components"

Item {
    id: gridRoot

    Flow {
        id: cardsFlow
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        flow: Flow.LeftToRight
        property real cardWidth: Math.max(180, (width - (spacing * 3)) / 4)
        property real cardHeight: 150

        ParameterCard {
            width: cardsFlow.cardWidth
            height: cardsFlow.cardHeight
            title: qsTr("Vehicle Speed")
            unit: qsTr("km/h")
            iconSource: "../assets/parametersCard/speed.svg"
            minValue: 0
            maxValue: 255
            step: 1
            value: ecuModel.speed
            onValueChanged: ecuModel.speed = value
        }

        ParameterCard {
            width: cardsFlow.cardWidth
            height: cardsFlow.cardHeight
            title: qsTr("Engine RPM")
            unit: qsTr("rpm")
            iconSource: "../assets/parametersCard/engine.svg"
            minValue: 0
            sizeVariant: 1
            maxValue: 15000
            step: 50
            value: ecuModel.rpm
            onValueChanged: ecuModel.rpm = value
        }

        ParameterCard {
            width: cardsFlow.cardWidth
            height: cardsFlow.cardHeight
            title: qsTr("Coolant Temp")
            unit: qsTr("°C")
            minValue: -40
            maxValue: 150
            step: 1
            iconSource: "../assets/parametersCard/temp.svg"
            value: ecuModel.coolantTemp
            onValueChanged: ecuModel.coolantTemp = Math.round(value)
        }

        ParameterCard {
            width: cardsFlow.cardWidth
            height: cardsFlow.cardHeight
            title: qsTr("Battery Voltage")
            unit: qsTr("V")
            sizeVariant: 2
            iconSource: "../assets/parametersCard/voltage.svg"
            minValue: 0
            maxValue: 18
            step: 0.1
            value: ecuModel.voltage
            onValueChanged: ecuModel.voltage = value
        }

        ParameterCard {
            width: cardsFlow.cardWidth
            height: cardsFlow.cardHeight
            title: qsTr("Engine Load")
            unit: qsTr("%")
            iconSource: "../assets/parametersCard/engine.svg"
            minValue: 0
            maxValue: 100
            step: 1
            value: ecuModel.engineLoad
            onValueChanged: ecuModel.engineLoad = Math.round(value)
        }

        ParameterCard {
            width: cardsFlow.cardWidth
            height: cardsFlow.cardHeight
            title: qsTr("Throttle Position")
            unit: qsTr("%")
            iconSource: "../assets/parametersCard/engine.svg"
            minValue: 0
            maxValue: 100
            step: 1
            value: ecuModel.throttlePosition
            onValueChanged: ecuModel.throttlePosition = Math.round(value)
        }

    }
}
