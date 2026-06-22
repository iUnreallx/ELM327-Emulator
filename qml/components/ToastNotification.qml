import QtQuick 2.15

Rectangle {
    id: toast
    width: messageText.implicitWidth + 40
    height: 40
    anchors.horizontalCenter: parent.horizontalCenter
    y: parent.height
    radius: 8
    z: 100

    // Свойства для кастомизации цветов
    readonly property color colorError: "#E11D48"
    readonly property color colorSuccess: "#10B981"

    Text {
        id: messageText
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: 14
        font.bold: true
    }

    PropertyAnimation {
        id: showAnimation
        target: toast
        property: "y"
        to: parent.height - 80
        duration: 300
        easing.type: Easing.OutBack
    }

    PropertyAnimation {
        id: hideAnimation
        target: toast
        property: "y"
        to: parent.height
        duration: 300
        easing.type: Easing.InBack
    }

    Timer {
        id: toastTimer
        interval: 3000
        onTriggered: hideAnimation.start()
    }

    function show(msg, isError) {
        messageText.text = msg;
        toast.color = isError ? colorError : colorSuccess;

        hideAnimation.stop();
        showAnimation.start();
        toastTimer.restart();
    }
}
