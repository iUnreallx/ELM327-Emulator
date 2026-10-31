import QtQuick
import QtQuick.Layouts

/// Карточка (e-card из дизайна): радиус 28, плоская поверхность, тонкая обводка.
/// Содержимое кладётся прямо внутрь (ColumnLayout). `pop` ≥ 0 — пружинное появление с задержкой pop*60 мс.
Rectangle {
    id: root

    default property alias content: holder.data
    property int padding: 22
    property alias spacing: holder.spacing
    property int pop: -1

    implicitHeight: holder.implicitHeight + padding * 2
    radius: Theme.rXl
    color: Theme.surface
    border.width: 1
    border.color: Theme.hairline
    Behavior on color { ColorAnimation { duration: 300 } }

    transform: Translate { id: pt }

    function replay() { if (pop >= 0) popAnim.restart() }
    onVisibleChanged: if (visible) replay()
    Component.onCompleted: if (visible) replay()

    SequentialAnimation {
        id: popAnim
        PropertyAction { target: root; property: "opacity"; value: 0 }
        PauseAnimation { duration: Math.max(0, root.pop) * 60 }
        ParallelAnimation {
            NumberAnimation { target: root; property: "opacity"; from: 0; to: 1; duration: 450 }
            NumberAnimation { target: pt; property: "y"; from: 18; to: 0; duration: 700; easing.type: Easing.OutBack; easing.overshoot: 1.3 }
        }
    }

    ColumnLayout {
        id: holder
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: 0
    }
}
