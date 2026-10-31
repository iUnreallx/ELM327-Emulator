import QtQuick
import QtQuick.Layouts

/// Большой заголовок страницы: при прокрутке уменьшается и растворяется (появляется компактный в шапке)
ColumnLayout {
    id: root

    property string title: ""
    property string subtitle: ""
    property real scroll: 0

    spacing: 6
    opacity: Math.max(0, Math.min(1, 1 - (scroll - 30) / 70))

    Text {
        text: root.title
        color: Theme.label
        font.family: Theme.fontFamily
        font.pixelSize: 44
        font.weight: Font.ExtraBold
        font.letterSpacing: -2
        scale: 1 - Math.min(1, root.scroll / 220) * 0.12
        transformOrigin: Item.Left
    }
    Text {
        text: root.subtitle
        color: Theme.label2
        font.family: Theme.fontFamily
        font.pixelSize: 17
        opacity: Math.max(0, 1 - root.scroll / 50)
    }
}
