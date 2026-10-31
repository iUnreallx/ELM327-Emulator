pragma Singleton
import QtQuick

/// Описание параметров: диапазоны, единицы, PID, порог «красной зоны», шкала спидометра.
/// `target` — откуда брать значение: "ecu" (ecuModel) или "delay" (delayManager).
QtObject {
    readonly property var order: ["speed", "rpm", "temp", "volt", "load", "thr"]
    readonly property var statOrder: ["temp", "volt", "load", "thr"]

    readonly property var defs: ({
        speed: { title: "Vehicle Speed", short: "Speed", unit: "km/h", icon: "gauge", tone: "blue", target: "ecu", prop: "speed",
                 from: 0, to: 255, step: 1, dec: 0, warn: 200, pid: "010D", major: 40, minor: 10, labelDiv: 1 },
        rpm:   { title: "Engine RPM", short: "RPM", unit: "rpm", icon: "reset", tone: "orange", target: "ecu", prop: "rpm",
                 from: 0, to: 8000, step: 50, dec: 0, warn: 6500, pid: "010C", major: 1000, minor: 250, labelDiv: 1000 },
        temp:  { title: "Coolant", short: "Coolant", unit: "°C", icon: "temp", tone: "red", target: "ecu", prop: "coolantTemp",
                 from: -40, to: 150, step: 1, dec: 0, warn: 105, pid: "0105" },
        volt:  { title: "Voltage", short: "Battery", unit: "V", icon: "bolt", tone: "yellow", target: "ecu", prop: "voltage",
                 from: 0, to: 18, step: 0.1, dec: 1, warn: 15, pid: "0142" },
        load:  { title: "Engine load", short: "Load", unit: "%", icon: "load", tone: "purple", target: "ecu", prop: "engineLoad",
                 from: 0, to: 100, step: 1, dec: 0, warn: 90, pid: "0104" },
        thr:   { title: "Throttle", short: "Throttle", unit: "%", icon: "throttle", tone: "teal", target: "ecu", prop: "throttlePosition",
                 from: 0, to: 100, step: 1, dec: 0, warn: 95, pid: "0111" },
        at:    { title: "AT response", unit: "ms", target: "delay", prop: "atDelay", from: 0, to: 2000, step: 10, dec: 0, warn: 1e9, pid: "",
                 desc: "Reply time to AT commands" },
        obd:   { title: "OBD response", unit: "ms", target: "delay", prop: "obdDelay", from: 0, to: 1000, step: 10, dec: 0, warn: 1e9, pid: "",
                 desc: "Reply time to PID requests" },
        jit:   { title: "Jitter", unit: "ms", target: "delay", prop: "jitter", from: 0, to: 500, step: 5, dec: 0, warn: 1e9, pid: "",
                 desc: "Random ± added to every reply" }
    })

    readonly property var scenarioOrder: ["Idle", "City", "Highway", "Overheat", "Redline"]
    readonly property var scenarioIcons: ({ Idle: "sc-idle", City: "sc-city", Highway: "sc-highway", Overheat: "sc-overheat", Redline: "sc-redline" })
    readonly property var scenarios: ({
        "Idle":     { speed: 0,   rpm: 800,  coolantTemp: 90,  voltage: 14.1, engineLoad: 18, throttlePosition: 12 },
        "City":     { speed: 46,  rpm: 2100, coolantTemp: 92,  voltage: 14.0, engineLoad: 42, throttlePosition: 28 },
        "Highway":  { speed: 118, rpm: 3100, coolantTemp: 94,  voltage: 14.2, engineLoad: 56, throttlePosition: 38 },
        "Overheat": { speed: 60,  rpm: 2600, coolantTemp: 118, voltage: 13.6, engineLoad: 70, throttlePosition: 44 },
        "Redline":  { speed: 210, rpm: 7400, coolantTemp: 104, voltage: 13.8, engineLoad: 96, throttlePosition: 92 }
    })

    readonly property var profileOrder: ["Default", "Instant", "Slow", "Chaotic"]
    readonly property var profileIcons: ({ Default: "sliders", Instant: "bolt", Slow: "hourglass", Chaotic: "flame" })
    readonly property var profiles: ({
        "Default": { atDelay: 500,  obdDelay: 50,  jitter: 0 },
        "Instant": { atDelay: 0,    obdDelay: 0,   jitter: 0 },
        "Slow":    { atDelay: 1500, obdDelay: 300, jitter: 100 },
        "Chaotic": { atDelay: 800,  obdDelay: 400, jitter: 500 }
    })

    /// Справочник команд: [группа, код, описание, ответ, префикс-команда?]
    readonly property var atCommands: [
        ["General", "ATZ", "Reset the adapter", "ELM327 v1.5"],
        ["General", "ATWS", "Warm start, no LED test", "ELM327 v1.5"],
        ["General", "ATI", "Print the version string", "ELM327 v1.5"],
        ["General", "AT@1", "Device description", "OBDII to RS232 Interpreter"],
        ["General", "AT@2", "Device identifier", "ELM327 EMU"],
        ["General", "ATD", "Set all to defaults", "OK"],
        ["General", "ATLP", "Low power mode", "OK"],
        ["Formatting", "ATE0", "Echo off", "OK"], ["Formatting", "ATE1", "Echo on", "OK"],
        ["Formatting", "ATL0", "Linefeeds off", "OK"], ["Formatting", "ATL1", "Linefeeds on", "OK"],
        ["Formatting", "ATS0", "Spaces off", "OK"], ["Formatting", "ATS1", "Spaces on", "OK"],
        ["Formatting", "ATH0", "Headers off", "OK"], ["Formatting", "ATH1", "Headers on", "OK"],
        ["Formatting", "ATCAF0", "CAN auto formatting off", "OK"], ["Formatting", "ATCAF1", "CAN auto formatting on", "OK"],
        ["Protocol", "ATSP0", "Set protocol: automatic", "OK"],
        ["Protocol", "ATSP6", "Set protocol: CAN 11/500", "OK", true],
        ["Protocol", "ATTP6", "Try protocol 6", "OK", true],
        ["Protocol", "ATDP", "Describe current protocol", "AUTO, ISO 15765-4 (CAN 11/500)"],
        ["Protocol", "ATDPN", "Protocol number", "A6"],
        ["Timing", "ATAT0", "Adaptive timing off", "OK"], ["Timing", "ATAT1", "Adaptive timing auto 1", "OK"], ["Timing", "ATAT2", "Adaptive timing auto 2", "OK"],
        ["Timing", "ATST", "Set response timeout (ATST hh)", "OK", true],
        ["Timing", "ATSH", "Set header (ATSH xyz)", "OK", true],
        ["Voltage", "ATRV", "Read battery voltage", "@volt"]
    ]

    readonly property var pidList: [
        ["Mode 01", "0100", "Supported PIDs 01–20", "41 00 BE 3F A8 13", ""],
        ["Mode 01", "0104", "Engine load (%)", "@load", "load"],
        ["Mode 01", "0105", "Coolant (°C)", "@temp", "temp"],
        ["Mode 01", "010C", "Engine RPM (rpm)", "@rpm", "rpm"],
        ["Mode 01", "010D", "Speed (km/h)", "@speed", "speed"],
        ["Mode 01", "0111", "Throttle (%)", "@thr", "thr"],
        ["Mode 01", "0142", "Voltage (V)", "@volt", "volt"]
    ]

    readonly property var accents: [
        { n: "Orange", c: "#ff9f0a" }, { n: "Amber", c: "#ffd60a" }, { n: "Lime", c: "#a3e635" },
        { n: "Green", c: "#30d158" }, { n: "Mint", c: "#2dd4bf" }, { n: "Cyan", c: "#40c8e0" },
        { n: "Blue", c: "#0a84ff" }, { n: "Indigo", c: "#5e5ce6" }, { n: "Purple", c: "#bf5af2" },
        { n: "Pink", c: "#ff375f" }, { n: "Red", c: "#ff453a" }, { n: "Mono", c: "mono" }
    ]

    function hex2(n) {
        var s = Math.max(0, Math.round(n)).toString(16).toUpperCase()
        return s.length < 2 ? "0" + s : s
    }

    /// Ответ Mode 01, который уйдёт приложению
    function response(key, v) {
        var r
        switch (key) {
        case "speed": return "41 0D " + hex2(v)
        case "rpm":   r = Math.round(v * 4);    return "41 0C " + hex2(r >> 8) + " " + hex2(r & 255)
        case "temp":  return "41 05 " + hex2(v + 40)
        case "volt":  r = Math.round(v * 1000); return "41 42 " + hex2(r >> 8) + " " + hex2(r & 255)
        case "load":  return "41 04 " + hex2(v * 2.55)
        case "thr":   return "41 11 " + hex2(v * 2.55)
        }
        return ""
    }
}
