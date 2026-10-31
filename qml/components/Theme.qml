pragma Singleton
import QtQuick

/// Дизайн-токены (iOS-стиль: плоские поверхности, системные цвета, акцент на выбор).
/// Тема переключается свойством `dark`, акцент — `accent`.
QtObject {
    id: root

    property bool dark: true

    // акцент выбирается пользователем (по умолчанию — оранжевый)
    /// ключ акцента: "#rrggbb" или "mono"
    property string accentKey: "#ff9f0a"
    readonly property color accent: accentKey === "mono" ? (dark ? "#ffffff" : "#000000") : accentKey
    readonly property color accentFg: {
        var c = Qt.color(accent)
        return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) > 0.62 ? "#000000" : "#ffffff"
    }
    /// акцент для текстовых действий (в mono — системный синий, как в iOS)
    readonly property color accentTint: accentKey === "mono" ? blue : accent

    // ── поверхности ──
    readonly property color bg: dark ? "#000000" : "#f2f2f7"
    readonly property color surface: dark ? "#1c1c1e" : "#ffffff"
    readonly property color surface2: dark ? "#2c2c2e" : "#f2f2f7"
    readonly property color surface3: dark ? "#3a3a3c" : "#e9e9ee"
    readonly property color group: dark ? Qt.rgba(1, 1, 1, 0.05) : "#f2f2f7"
    readonly property color fill: dark ? Qt.rgba(120 / 255, 120 / 255, 128 / 255, 0.24) : Qt.rgba(120 / 255, 120 / 255, 128 / 255, 0.12)
    readonly property color fill2: dark ? Qt.rgba(120 / 255, 120 / 255, 128 / 255, 0.36) : Qt.rgba(120 / 255, 120 / 255, 128 / 255, 0.20)
    readonly property color separator: dark ? Qt.rgba(84 / 255, 84 / 255, 88 / 255, 0.55) : Qt.rgba(60 / 255, 60 / 255, 67 / 255, 0.14)
    readonly property color hairline: dark ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(60 / 255, 60 / 255, 67 / 255, 0.10)

    // ── текст ──
    readonly property color label: dark ? "#ffffff" : "#000000"
    readonly property color label2: dark ? Qt.rgba(235 / 255, 235 / 255, 245 / 255, 0.6) : Qt.rgba(60 / 255, 60 / 255, 67 / 255, 0.62)
    readonly property color label3: dark ? Qt.rgba(235 / 255, 235 / 255, 245 / 255, 0.3) : Qt.rgba(60 / 255, 60 / 255, 67 / 255, 0.32)

    // ── системные цвета ──
    readonly property color blue: dark ? "#0a84ff" : "#007aff"
    readonly property color green: dark ? "#30d158" : "#34c759"
    readonly property color red: dark ? "#ff453a" : "#ff3b30"
    readonly property color orange: dark ? "#ff9f0a" : "#ff9500"
    readonly property color yellow: dark ? "#ffd60a" : "#ffcc00"
    readonly property color teal: dark ? "#40c8e0" : "#30b0c7"
    readonly property color purple: dark ? "#bf5af2" : "#af52de"
    readonly property color pink: dark ? "#ff375f" : "#ff2d55"
    readonly property color gray: "#8e8e93"
    readonly property color indigo: dark ? "#5e5ce6" : "#5856d6"

    function tint(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

    // ── форма и движение ──
    readonly property int rXs: 8
    readonly property int rSm: 12
    readonly property int rMd: 16
    readonly property int rLg: 22
    readonly property int rXl: 28

    readonly property int springMs: 450
    readonly property real springOvershoot: 1.56

    // ── шрифты ──
    readonly property string fontFamily: "Inter"
    readonly property string monoFamily: "Cascadia Mono"

    readonly property int pagePadding: 24
    readonly property int gap: 18
}
