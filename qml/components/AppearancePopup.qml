import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

/// Окно оформления: тема, 12 акцентов и свой цвет (ползунок оттенка)
Rectangle {
    id: root

    property bool shown: false
    property bool customOpen: false
    readonly property bool customActive: {
        for (var i = 0; i < ParamDefs.accents.length; ++i)
            if (ParamDefs.accents[i].c === Theme.accentKey) return false
        return true
    }
    property real hue: 0.08

    width: 312
    height: col.implicitHeight + 32
    radius: 22
    color: Theme.dark ? Qt.rgba(36 / 255, 36 / 255, 38 / 255, 0.98) : Qt.rgba(1, 1, 1, 0.98)
    border.width: 1
    border.color: Theme.separator
    opacity: shown ? 1 : 0
    scale: shown ? 1 : 0.85
    transformOrigin: Item.TopRight
    visible: opacity > 0.01
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on scale { NumberAnimation { duration: 450; easing.type: Easing.OutBack; easing.overshoot: 1.4 } }
    onShownChanged: if (!shown) customOpen = false

    function applyHue(h) {
        hue = Math.max(0, Math.min(1, h))
        var c = Qt.hsla(hue, 0.85, 0.55, 1)
        function hx(v) { var s = Math.round(v * 255).toString(16); return s.length < 2 ? "0" + s : s }
        Theme.accentKey = "#" + hx(c.r) + hx(c.g) + hx(c.b)
    }

    MouseArea { anchors.fill: parent } // клики по окну не закрывают его

    ColumnLayout {
        id: col
        x: 16
        y: 16
        width: parent.width - 32
        spacing: 10

        Caption { text: qsTr("Theme") }
        Segmented {
            Layout.fillWidth: true
            Layout.bottomMargin: 8
            block: true
            model: [qsTr("Light"), qsTr("Dark")]
            currentIndex: Theme.dark ? 1 : 0
            onPicked: function (i) { Theme.dark = i === 1 }
        }

        Caption { text: qsTr("Accent") }
        Flow {
            Layout.fillWidth: true
            spacing: 11

            Repeater {
                model: ParamDefs.accents
                delegate: Rectangle {
                    readonly property bool on: Theme.accentKey === modelData.c
                    width: 34
                    height: 34
                    radius: 17
                    color: modelData.c === "mono" ? "#000000" : modelData.c
                    border.width: on ? 3 : 1.5
                    border.color: on ? Theme.label : Theme.separator
                    scale: sw.pressed ? 0.86 : (sw.containsMouse ? 1.12 : 1)
                    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }

                    Rectangle { // «просвет» между цветом и обводкой
                        anchors.fill: parent
                        anchors.margins: 3
                        radius: width / 2
                        color: "transparent"
                        border.width: on ? 2 : 0
                        border.color: Theme.surface
                    }
                    Shape { // mono: половина чёрная, половина белая
                        visible: modelData.c === "mono"
                        anchors.centerIn: parent
                        width: 28; height: 28
                        ShapePath {
                            fillColor: "#ffffff"
                            strokeWidth: 0
                            PathAngleArc { centerX: 14; centerY: 14; radiusX: 14; radiusY: 14; startAngle: -135; sweepAngle: 180 }
                        }
                    }
                    MouseArea {
                        id: sw
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { Theme.accentKey = modelData.c; root.customOpen = false }
                    }
                }
            }

            // свой цвет
            Rectangle {
                width: 34
                height: 34
                radius: 17
                color: "transparent"
                border.width: root.customActive ? 3 : 1.5
                border.color: root.customActive ? Theme.label : Theme.separator
                scale: cw.pressed ? 0.86 : (cw.containsMouse ? 1.12 : 1)
                Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }
                Shape {
                    anchors.centerIn: parent
                    width: 28; height: 28
                    layer.enabled: true
                    layer.samples: 4
                    ShapePath {
                        strokeWidth: 0
                        fillGradient: ConicalGradient {
                            centerX: 14; centerY: 14; angle: 0
                            GradientStop { position: 0.00; color: "#ff375f" }
                            GradientStop { position: 0.17; color: "#ff9f0a" }
                            GradientStop { position: 0.33; color: "#ffd60a" }
                            GradientStop { position: 0.50; color: "#30d158" }
                            GradientStop { position: 0.66; color: "#40c8e0" }
                            GradientStop { position: 0.83; color: "#bf5af2" }
                            GradientStop { position: 1.00; color: "#ff375f" }
                        }
                        PathAngleArc { centerX: 14; centerY: 14; radiusX: 14; radiusY: 14; startAngle: 0; sweepAngle: 360 }
                    }
                }
                Rectangle {
                    visible: root.customActive
                    anchors.centerIn: parent
                    width: 16; height: 16; radius: 8
                    color: Theme.accent
                    border.width: 2
                    border.color: Theme.surface
                }
                MouseArea {
                    id: cw
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { root.customOpen = !root.customOpen; if (root.customOpen) root.applyHue(root.hue) }
                }
            }
        }

        // ползунок оттенка
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: root.customOpen ? 34 : 0
            opacity: root.customOpen ? 1 : 0
            clip: true
            Behavior on Layout.preferredHeight { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Rectangle {
                id: hueBar
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 14
                radius: 7
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.00; color: Qt.hsla(0.00, 0.85, 0.55, 1) }
                    GradientStop { position: 0.17; color: Qt.hsla(0.17, 0.85, 0.55, 1) }
                    GradientStop { position: 0.33; color: Qt.hsla(0.33, 0.85, 0.55, 1) }
                    GradientStop { position: 0.50; color: Qt.hsla(0.50, 0.85, 0.55, 1) }
                    GradientStop { position: 0.67; color: Qt.hsla(0.67, 0.85, 0.55, 1) }
                    GradientStop { position: 0.83; color: Qt.hsla(0.83, 0.85, 0.55, 1) }
                    GradientStop { position: 1.00; color: Qt.hsla(1.00, 0.85, 0.55, 1) }
                }
                Rectangle {
                    x: root.hue * (parent.width - width)
                    anchors.verticalCenter: parent.verticalCenter
                    width: 22; height: 22; radius: 11
                    color: "white"
                    border.width: 3
                    border.color: Theme.accent
                }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onPressed: function (e) { root.applyHue((e.x - 8 - 11) / (hueBar.width - 22)) }
                    onPositionChanged: function (e) { if (pressed) root.applyHue((e.x - 8 - 11) / (hueBar.width - 22)) }
                }
            }
        }
    }
}
