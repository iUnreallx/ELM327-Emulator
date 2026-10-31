import QtQuick
import QtQuick.Shapes

/// Спидометр: толстая дуга со свечением, засечки с подписями, красная зона и парящая стрелка.
/// Число в центре — одометр; клик по нему просит ввод значения.
Item {
    id: root

    property real value: 0
    property real from: 0
    property real to: 100
    property real warnAt: 1e9
    property int decimals: 0
    property string unit: ""
    property real major: 10
    property real minor: 5
    property real labelDiv: 1
    signal editRequested()

    readonly property real frac: Math.max(0, Math.min(1, (value - from) / (to - from)))
    readonly property bool warn: value >= warnAt
    readonly property color accent: warn ? Theme.red : Theme.accent

    property real shown: frac
    Behavior on shown { NumberAnimation { duration: 800; easing.type: Easing.OutBack; easing.overshoot: 1.0 } }

    // геометрия в «координатах мока» 240x204, центр (120,120), радиус дуги 82
    readonly property real k: width / 240
    readonly property int tickCount: Math.floor((to - from) / minor + 1e-6)

    implicitWidth: 360
    implicitHeight: width * 204 / 240

    // внутренний диск
    Rectangle {
        x: 54 * root.k; y: 54 * root.k
        width: 132 * root.k; height: width
        radius: width / 2
        color: Theme.surface2
        opacity: 0.55
    }

    // засечки + подписи
    Item {
        id: art
        width: 240
        height: 204
        scale: root.k
        transformOrigin: Item.TopLeft

        Repeater {
            model: root.tickCount + 1
            delegate: Item {
                readonly property real v: root.from + index * root.minor
                readonly property bool big: Math.abs(v % root.major) < 1e-6
                readonly property bool red: v >= root.warnAt - 1e-6
                readonly property bool lit: v <= root.value + 1e-6
                x: 120
                y: 120
                rotation: 135 + 270 * (v - root.from) / (root.to - root.from)

                Rectangle {
                    x: big ? 92 : 95
                    y: big ? -1 : -0.6
                    width: big ? 8 : 5
                    height: big ? 2 : 1.2
                    radius: height / 2
                    color: lit ? (root.warn || red ? Theme.red : Theme.accent)
                               : (red ? Qt.tint(Theme.label3, Qt.rgba(1, 0.27, 0.23, 0.45))
                                      : (big ? Theme.label2 : Theme.label3))
                    Behavior on color { ColorAnimation { duration: 400 } }
                }
            }
        }

        Repeater {
            model: root.tickCount + 1
            delegate: Text {
                readonly property real v: root.from + index * root.minor
                readonly property real a: (135 + 270 * (v - root.from) / (root.to - root.from)) * Math.PI / 180
                visible: Math.abs(v % root.major) < 1e-6
                x: 120 + 113 * Math.cos(a) - width / 2
                y: 120 + 113 * Math.sin(a) - height / 2
                text: Math.round(v / root.labelDiv)
                color: Theme.label2
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.weight: Font.DemiBold
            }
        }
    }

    // дуги в реальном размере (слой не масштабируем — иначе «ступеньки»)
    Shape {
        id: arcs
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 8
        readonly property real r: 82 * root.k
        readonly property real cx: 120 * root.k
        readonly property real cy: 120 * root.k
        readonly property real redStart: 135 + 270 * Math.max(0, Math.min(1, (root.warnAt - root.from) / (root.to - root.from)))

        ShapePath { // трек
            strokeColor: Theme.fill2
            strokeWidth: 13 * root.k
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: arcs.cx; centerY: arcs.cy; radiusX: arcs.r; radiusY: arcs.r; startAngle: 135; sweepAngle: 270 }
        }
        ShapePath { // красная зона
            strokeColor: Qt.rgba(1, 0.27, 0.23, 0.30)
            strokeWidth: 13 * root.k
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap
            PathAngleArc { centerX: arcs.cx; centerY: arcs.cy; radiusX: arcs.r; radiusY: arcs.r; startAngle: arcs.redStart; sweepAngle: Math.max(0.01, 405 - arcs.redStart) }
        }
        ShapePath { // свечение
            strokeColor: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, glowPulse.alpha)
            strokeWidth: 24 * root.k
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc { centerX: arcs.cx; centerY: arcs.cy; radiusX: arcs.r; radiusY: arcs.r; startAngle: 135; sweepAngle: Math.max(0.01, 270 * root.shown) }
        }
        ShapePath { // значение
            strokeColor: root.accent
            strokeWidth: 13 * root.k
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            Behavior on strokeColor { ColorAnimation { duration: 300 } }
            PathAngleArc { centerX: arcs.cx; centerY: arcs.cy; radiusX: arcs.r; radiusY: arcs.r; startAngle: 135; sweepAngle: Math.max(0.01, 270 * root.shown) }
        }
    }

    QtObject {
        id: glowPulse
        property real alpha: 0.2
        SequentialAnimation on alpha {
            running: root.warn
            loops: Animation.Infinite
            NumberAnimation { to: 0.38; duration: 600; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.14; duration: 600; easing.type: Easing.InOutSine }
        }
    }

    // стрелка
    Item {
        x: 120 * root.k
        y: 120 * root.k
        rotation: 135 + 270 * root.shown
        Rectangle { // свечение стрелки
            x: 54 * root.k; y: -3.6 * root.k
            width: 47 * root.k; height: 7.2 * root.k
            radius: height / 2
            color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.30)
        }
        Rectangle {
            x: 56 * root.k; y: -1.7 * root.k
            width: 43 * root.k; height: 3.4 * root.k
            radius: height / 2
            color: Theme.label
        }
    }

    // число + единицы
    Odo {
        id: odo
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height * 0.58 - root.width * 0.16 * 0.62
        pixelSize: Math.max(24, Math.round(root.width * 0.16))
        value: root.value
        decimals: root.decimals
        clickable: true
        onClicked: root.editRequested()
    }
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        y: odo.y + odo.height + 2
        text: root.unit
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 0.8
        color: Theme.label2
        font.family: Theme.fontFamily
        font.pixelSize: Math.max(11, Math.round(root.width * 0.034))
        font.weight: Font.DemiBold
    }
}
