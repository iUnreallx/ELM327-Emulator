import QtQuick

/// Корень страницы: появление с лёгкой пружиной при переключении
Item {
    id: root

    /// прокрутка содержимого (для сворачивания большого заголовка)
    property real scrollY: 0

    transform: Translate { id: shift }

    onVisibleChanged: {
        if (visible) enter.restart()
    }

    ParallelAnimation {
        id: enter
        NumberAnimation { target: root; property: "opacity"; from: 0; to: 1; duration: 300 }
        NumberAnimation { target: shift; property: "y"; from: 14; to: 0; duration: 550; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
    }
}
