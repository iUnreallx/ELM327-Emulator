import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    id: root
    visible: true
    title: "Obd2 Emulator"
    width: 350
    height: 495
    x: 150
    y: 120
    Material.theme: Material.Dark

    property bool isOverlayVisible: false
    property string currentPage: "MainPage.qml"
    property bool allowResize: false

    Rectangle {
        id: globalOverlay
        anchors.fill: parent
        color: "black"
        opacity: isOverlayVisible ? 1 : 0.0
        visible: isOverlayVisible
        z: 3
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            propagateComposedEvents: false
            preventStealing: true
            onClicked: root.isOverlayVisible = false
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
    }

    // Font Loaders
    FontLoader {
        id: cleanerFont
        source: "assets/fonts/Ubuntu-Bold.ttf"
    }

    FontLoader {
        id: cleanerFontRegular
        source: "assets/fonts/Ubuntu-Regular.ttf"
    }


    Component.onCompleted: {
        root.maximumWidth = 350;
        root.maximumHeight = 495;
        root.minimumWidth = 350;
        root.minimumHeight = 495;
    }

    Loader {
        id: pageLoader
        anchors.fill: parent
        source: currentPage
        z: -1
    }

    onAllowResizeChanged: {
        if (allowResize) {

            root.maximumWidth = 9999;
            root.maximumHeight = 9999;
            root.minimumWidth = 100;
            root.minimumHeight = 100;
        } else {

            root.maximumWidth = 350;
            root.maximumHeight = 495;
            root.minimumWidth = 350;
            root.minimumHeight = 495;

        }
    }


    function changePage(page) {
        currentPage = page;
        if (page !== "MainPage.qml") {
            allowResize = true;
            if (page === "Obd2Screen.qml") {
                console.log("good")
                root.minimumWidth = 800;
                root.minimumHeight = 615;
                root.width = 950
                root.height = 615
                // root.x = (Screen.width - root.width) / 2;
                // root.y = (Screen.height - root.height) / 2;
            }
        } else {
            allowResize = false;


        }
    }



}
