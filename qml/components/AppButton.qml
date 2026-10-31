import QtQuick
import QtQuick.Layouts

/// Кнопка. kind: "filled" | "red" | "tinted" | "gray" | "danger". size: "sm" | "md" | "lg"
Rectangle {
    id: root

    property string text: ""
    property string iconName: ""
    property string trailingIcon: ""
    property string kind: "gray"
    property string size: "md"
    signal clicked()

    readonly property color base: kind === "filled" ? Theme.accent
                                : kind === "red" ? Theme.red
                                : kind === "tinted" ? Theme.accent
                                : kind === "danger" ? Theme.red
                                : Theme.fill
    readonly property color fg: kind === "filled" ? Theme.accentFg
                              : kind === "red" ? "#ffffff"
                              : kind === "tinted" ? Theme.accent
                              : kind === "danger" ? Theme.red
                              : Theme.label
    readonly property bool tintedKind: kind === "tinted" || kind === "danger"

    implicitHeight: size === "lg" ? 52 : (size === "sm" ? 32 : 40)
    implicitWidth: row.implicitWidth + (size === "sm" ? 28 : (size === "lg" ? 48 : 40))
    radius: size === "lg" ? Theme.rMd : height / 2

    color: tintedKind ? Theme.tint(base, mouse.containsMouse ? 0.24 : 0.15)
         : kind === "gray" ? (mouse.containsMouse ? Theme.fill2 : Theme.fill)
         : (mouse.containsMouse ? Qt.darker(base, 1.08) : base)
    Behavior on color { ColorAnimation { duration: 150 } }

    scale: mouse.pressed ? 0.95 : 1
    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 7

        Icon { visible: root.iconName !== ""; name: root.iconName; size: root.size === "sm" ? 14 : 16; color: root.fg }
        Text {
            visible: root.text !== ""
            text: root.text
            color: root.fg
            font.family: Theme.fontFamily
            font.pixelSize: root.size === "lg" ? 16 : (root.size === "sm" ? 14 : 15)
            font.weight: Font.DemiBold
        }
        Icon { visible: root.trailingIcon !== ""; name: root.trailingIcon; size: 14; color: root.fg }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
