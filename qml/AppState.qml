import QtQuick
import "components"

/// Общее состояние UI: параметры подключения, uptime, счётчики, модель логов,
/// доступ к значениям (ecuModel / delayManager) и сигналы для оверлеев.
/// Создаётся один раз в Main.qml и передаётся страницам как `app`.
Item {
    id: root
    visible: false

    readonly property bool connected: connManager.isConnected
    readonly property bool connecting: connManager.connecting

    /// 0 = Wi-Fi, 1 = Bluetooth, 2 = USB (как ждёт ConnectionManager::toggleConnection)
    property int connMode: 1
    property string ip: "192.168.0.10"
    property string port: "35000"
    property string com: ""
    property var ports: []

    property int uptime: 0
    property int txCount: 0
    property int rxCount: 0

    property bool simulate: false

    // страница Logs открыта — непрочитанные не копим
    property bool logsVisible: false
    property int unread: 0

    // сколько раз клиент присылал каждую команду (ключ — код из справочника)
    property var cmdUse: ({})
    signal commandSeen(string code)
    onLogsVisibleChanged: if (logsVisible) unread = 0

    function matchCommand(raw) {
        var m = raw.replace(/\s+/g, "").toUpperCase()
        var i
        for (i = 0; i < ParamDefs.atCommands.length; ++i)
            if (ParamDefs.atCommands[i][1] === m) return ParamDefs.atCommands[i][1]
        for (i = 0; i < ParamDefs.atCommands.length; ++i)
            if (ParamDefs.atCommands[i][4] && m.indexOf(ParamDefs.atCommands[i][1]) === 0) return ParamDefs.atCommands[i][1]
        for (i = 0; i < ParamDefs.pidList.length; ++i)
            if (ParamDefs.pidList[i][1] === m) return m
        return ""
    }

    /// ответ на команду из справочника (для превью-терминала)
    function answerFor(raw) {
        var m = raw.replace(/\s+/g, "").toUpperCase()
        var i, row
        for (i = 0; i < ParamDefs.atCommands.length; ++i) {
            row = ParamDefs.atCommands[i]
            if (row[1] === m || (row[4] && m.indexOf(row[1]) === 0)) return commandText(row[3])
        }
        for (i = 0; i < ParamDefs.pidList.length; ++i) {
            row = ParamDefs.pidList[i]
            if (row[1] === m) return commandText(row[3])
        }
        return "?"
    }

    function commandText(spec) {
        if (spec === "@volt") return value("volt").toFixed(1) + "V"
        if (spec.charAt(0) === "@") return ParamDefs.response(spec.substr(1), value(spec.substr(1)))
        return spec
    }

    readonly property alias logModel: logModel
    readonly property int maxLogLines: 1000

    readonly property var modeNames: ["Wi-Fi", "Bluetooth", "USB"]
    readonly property var modeIcons: ["wifi", "bt", "usb"]
    readonly property string endpoint: connMode === 0 ? ip + ":" + port : (com !== "" ? com : "no port")

    // ── сигналы для оверлеев Main.qml ──
    signal notify(string title, string desc, string kind, string iconName)          // Dynamic Island
    signal toastRequested(string title, string desc, string kind, string iconName, var undo)   // стопка тостов
    signal editRequested(string key)
    signal portsRequested()
    signal confirmRequested(string title, string message, string okText, bool destructive, var callback)
    signal traffic()

    /// событие в Dynamic Island (статусы, предупреждения)
    function island(title, desc, kind, iconName) {
        notify(title, desc || "", kind || "green", iconName || "check")
    }

    /// тост в правом нижнем углу; undo — необязательная функция «Отменить»
    function toast(title, desc, kind, iconName, undo) {
        toastRequested(title, desc || "", kind || "green", iconName || "check", undo || null)
    }

    /// старт без вопросов, остановка — с подтверждением
    function requestToggle() {
        if (connected) {
            confirmRequested(qsTr("Stop the server?"),
                             qsTr("Connected clients will be dropped (up for %1).").arg(formatUptime(uptime)),
                             qsTr("Stop"), true, function () { toggleConnection() })
        } else {
            toggleConnection()
        }
    }

    function toggleConnection() {
        if (connecting) return
        if (!connected && connMode !== 0)
            island(qsTr("Connecting…"), qsTr("Opening %1").arg(com), "blue", "plug")
        connManager.toggleConnection(connMode, ip, port, com)
    }

    function refreshPorts() {
        ports = connManager.getAvailablePorts()
        if (ports.length > 0 && ports.indexOf(com) < 0)
            com = ports[0]
    }

    function formatUptime(secs) {
        function p(n) { return n < 10 ? "0" + n : "" + n }
        return p(Math.floor(secs / 3600)) + ":" + p(Math.floor((secs % 3600) / 60)) + ":" + p(secs % 60)
    }

    // ── значения параметров ──
    function value(key) {
        var d = ParamDefs.defs[key]
        return d.target === "delay" ? delayManager[d.prop] : ecuModel[d.prop]
    }

    function setValue(key, v) {
        var d = ParamDefs.defs[key]
        v = Math.max(d.from, Math.min(d.to, Number(v)))
        v = d.dec > 0 ? Math.round(v * 10) / 10 : Math.round(v / d.step) * d.step
        v = Math.max(d.from, Math.min(d.to, v))
        if (d.target === "delay") delayManager[d.prop] = v
        else ecuModel[d.prop] = v
    }

    function format(key) {
        return Number(value(key)).toFixed(ParamDefs.defs[key].dec)
    }

    function fraction(key) {
        var d = ParamDefs.defs[key]
        return Math.max(0, Math.min(1, (value(key) - d.from) / (d.to - d.from)))
    }

    // последний применённый сценарий (на нём «стоит» симуляция поездки)
    property string scenario: "Idle"

    function applyScenario(name) {
        var sc = ParamDefs.scenarios[name]
        scenario = name
        applyPreset(sc)
        toast(qsTr("%1 scenario").arg(name),
              sc.speed + " km/h · " + sc.rpm + " rpm · " + sc.coolantTemp + " °C", "acc", ParamDefs.scenarioIcons[name])
        if (sc.coolantTemp >= ParamDefs.defs.temp.warn)
            island(qsTr("Overheat scenario"), qsTr("Coolant is above %1 °C").arg(ParamDefs.defs.temp.warn), "red", "alert")
    }

    function applyProfile(name) {
        var p = ParamDefs.profiles[name]
        applyPreset(p)
        toast(qsTr("%1 profile").arg(name), p.atDelay + " / " + p.obdDelay + " / ±" + p.jitter + " ms", "acc", ParamDefs.profileIcons[name])
    }

    function applyPreset(map) {
        for (var k in map) {
            if (k === "atDelay" || k === "obdDelay" || k === "jitter") delayManager[k] = map[k]
            else ecuModel[k] = map[k]
        }
    }

    function presetActive(map) {
        for (var k in map) {
            var cur = (k === "atDelay" || k === "obdDelay" || k === "jitter") ? delayManager[k] : ecuModel[k]
            if (Math.abs(cur - map[k]) > 1e-6) return false
        }
        return true
    }

    // ── расшифровка трафика ──
    readonly property var pidNames: ({
        "0100": "Supported PIDs 01–20", "0104": "Engine Load", "0105": "Coolant Temp",
        "010C": "Engine RPM", "010D": "Vehicle Speed", "0111": "Throttle Position",
        "0142": "Battery Voltage"
    })

    function decode(isRx, msg) {
        var m = msg.replace(/\s+/g, "").toUpperCase()
        if (isRx) {
            if (pidNames[m]) return "Request · " + pidNames[m]
            if (m.indexOf("AT") === 0) return "Request · AT command"
            return ""
        }
        if (m.indexOf("41") === 0 && m.length >= 6) {
            var pid = m.substr(2, 2)
            var a = parseInt(m.substr(4, 2), 16)
            var b = m.length >= 8 ? parseInt(m.substr(6, 2), 16) : 0
            switch (pid) {
            case "0D": return a + " km/h"
            case "0C": return Math.round((a * 256 + b) / 4) + " rpm"
            case "05": return (a - 40) + " °C"
            case "04":
            case "11": return Math.round(a * 100 / 255) + " %"
            case "42": return ((a * 256 + b) / 1000).toFixed(1) + " V"
            case "00": return "Supported PIDs 01–20"
            }
        }
        if (m === "OK") return "OK"
        if (m.indexOf("NODATA") >= 0) return "No data"
        return ""
    }

    function isError(isRx, msg) {
        var m = msg.replace(/\s+/g, "").toUpperCase()
        return !isRx && (m.indexOf("NODATA") >= 0 || m === "?")
    }

    ListModel { id: logModel }

    Timer {
        interval: 1000
        repeat: true
        running: root.connected
        onTriggered: root.uptime++
    }

    // «Simulate drive»: скорость, обороты и температура двигаются сами
    property real simT: 0
    Timer {
        interval: 120
        repeat: true
        running: root.simulate
        onTriggered: {
            root.simT += 0.06
            var t = root.simT
            var sp = Math.max(0, Math.min(230, 70 + 60 * Math.sin(t * 0.55) + 18 * Math.sin(t * 1.7)))
            ecuModel.speed = Math.round(sp)
            ecuModel.rpm = Math.round(Math.max(0, Math.min(8000, (800 + sp * 28 + Math.sin(t * 4) * 120) / 50))) * 50
            ecuModel.coolantTemp = Math.round(ecuModel.coolantTemp + (92 + 6 * Math.sin(t * 0.2) - ecuModel.coolantTemp) * 0.05)
            ecuModel.voltage = Math.round((13.8 + 0.25 * Math.sin(t * 0.9)) * 10) / 10
            ecuModel.engineLoad = Math.round(Math.max(0, Math.min(100, 15 + sp * 0.3 + Math.sin(t * 2) * 6)))
            ecuModel.throttlePosition = Math.round(Math.max(0, Math.min(100, sp * 0.28 + Math.sin(t * 3) * 5)))
        }
    }

    Connections {
        target: connManager
        function onConnectionChanged(isConnected) {
            if (isConnected) root.uptime = 0
        }
    }

    Connections {
        target: logManager

        function onLogsAdded(isRx, msg, timestamp) {
            logModel.append({
                "isRx": isRx,
                "msg": msg,
                "timestamp": timestamp,
                "decoded": root.decode(isRx, msg),
                "isErr": root.isError(isRx, msg),
                "pinned": false
            })
            if (isRx) {
                root.rxCount++
                var code = root.matchCommand(msg)
                if (code !== "") {
                    var u = Object.assign({}, root.cmdUse)
                    u[code] = (u[code] || 0) + 1
                    root.cmdUse = u
                    root.commandSeen(code)
                }
                if (!root.logsVisible) root.unread++
            } else root.txCount++
            if (logModel.count > root.maxLogLines) logModel.remove(0)
            root.traffic()
        }

        function onLogsCleared() {
            logModel.clear()
            root.unread = 0
            root.rxCount = 0
            root.txCount = 0
        }
    }

    Component.onCompleted: refreshPorts()
}
