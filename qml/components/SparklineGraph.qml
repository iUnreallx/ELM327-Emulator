// components/SparklineGraph.qml
import QtQuick 2.15

Canvas {
    id: root
    antialiasing: true

    property var historyData: []
    property real minValue: 0
    property real maxValue: 100

    readonly property color lineColor: "#38BDF8"
    readonly property int lineWidth: 2

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        if (!historyData || historyData.length < 2) return

        ctx.beginPath()
        ctx.lineWidth = root.lineWidth
        ctx.strokeStyle = root.lineColor
        ctx.lineCap = "round"
        ctx.lineJoin = "round"

        var stepX = width / Math.max(1, historyData.length - 1)
        var range = maxValue - minValue
        if (range === 0) range = 1

        for (var i = 0; i < historyData.length; i++) {
            var x = i * stepX

            var safeValue = Math.max(minValue, Math.min(maxValue, historyData[i]))

            var y = height - ((safeValue - minValue) / range * height)

            if (i === 0) {
                ctx.moveTo(x, y)
            } else {
                ctx.lineTo(x, y)
            }
        }
        ctx.stroke()
    }
}
