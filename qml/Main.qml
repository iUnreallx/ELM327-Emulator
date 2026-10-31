import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtCore
import "components"
import "pages"

ApplicationWindow {
    id: window
    visible: true
    title: "Elm327 Emulator"
    width: 1280
    height: 800
    minimumWidth: 960
    minimumHeight: 620
    color: Theme.bg
    font.family: Theme.fontFamily
    // собственная шапка вместо системной: перетаскивание, свернуть/развернуть/закрыть и ресайз — ниже
    flags: Qt.Window | Qt.FramelessWindowHint
    Behavior on color { ColorAnimation { duration: 300 } }

    property int currentPage: 0
    /// "" | "edit" | "ports" | "confirm" | "appearance" | "palette"
    property string overlay: ""
    readonly property bool maximized: window.visibility === Window.Maximized
    onOverlayChanged: if (overlay === "") keys.forceActiveFocus()

    readonly property var pages: [
        { id: "overview",   name: qsTr("Overview"), icon: "overview" },
        { id: "connection", name: qsTr("Connect"),  icon: "wifi" },
        { id: "params",     name: qsTr("Params"),   icon: "sliders" },
        { id: "at",         name: qsTr("AT"),       icon: "terminal" },
        { id: "logs",       name: qsTr("Logs"),     icon: "doc" },
        { id: "delay",      name: qsTr("Delay"),    icon: "hourglass" }
    ]
    readonly property var pageTitles: [qsTr("Overview"), qsTr("Connection"), qsTr("Parameters"), qsTr("AT commands"), qsTr("Logs"), qsTr("Response delay")]
    readonly property var pageItems: [pOverview, pConnection, pParams, pAt, pLogs, pDelay]
    readonly property real scrollY: pageItems[currentPage].scrollY
    readonly property real headerP: Math.max(0, Math.min(1, (scrollY - 50) / 30))

    function goTo(i) {
        currentPage = i
        appState.logsVisible = (i === 4)
        keys.forceActiveFocus()
    }

    function statusToast() {
        island.show(appState.connected ? qsTr("Server is live") : qsTr("Server is stopped"),
                    appState.endpoint + " · " + appState.modeNames[appState.connMode] + " · " + appState.formatUptime(appState.uptime),
                    appState.connected ? "green" : "gray",
                    appState.connected ? "wifi" : "power")
    }

    function nextScenario() {
        var o = ParamDefs.scenarioOrder
        appState.applyScenario(o[(o.indexOf(appState.scenario) + 1) % o.length])
    }

    function toggleSim(c) {
        appState.simulate = c
        island.show(c ? qsTr("Simulating a drive") : qsTr("Simulation off"),
                    c ? qsTr("Values drift around the scenario") : qsTr("Values hold still"), c ? "green" : "gray", "car")
    }

    // Inter — шрифт дизайна (SIL OFL), вшит в ресурсы
    FontLoader { source: "assets/fonts/Inter-Regular.ttf" }
    FontLoader { source: "assets/fonts/Inter-Medium.ttf" }
    FontLoader { source: "assets/fonts/Inter-SemiBold.ttf" }
    FontLoader { source: "assets/fonts/Inter-Bold.ttf" }
    FontLoader { source: "assets/fonts/Inter-ExtraBold.ttf" }

    AppState { id: appState }

    Settings {
        id: prefs
        category: "ui3"
        property bool dark: true
        property string accent: "#ff9f0a"
    }
    Component.onCompleted: {
        Theme.dark = prefs.dark
        Theme.accentKey = prefs.accent
        Qt.callLater(function () { toasts.show(qsTr("Welcome"), qsTr("Press Ctrl F for the command palette."), "acc", "sparkle", null) })
    }
    Connections {
        target: Theme
        function onDarkChanged() { prefs.dark = Theme.dark }
        function onAccentKeyChanged() { prefs.accent = Theme.accentKey }
    }

    // ── сигналы состояния → оверлеи ──
    Connections {
        target: appState
        function onNotify(title, desc, kind, iconName) { island.show(title, desc, kind, iconName) }
        function onToastRequested(title, desc, kind, iconName, undo) { toasts.show(title, desc, kind, iconName, undo) }
        function onTraffic() { island.pulse() }
        function onEditRequested(key) {
            editSheet.openFor(key)
            window.overlay = "edit"
        }
        function onPortsRequested() { window.overlay = "ports" }
        function onConfirmRequested(title, message, okText, destructive, callback) {
            confirm.title = title
            confirm.message = message
            confirm.okText = okText
            confirm.destructive = destructive
            confirm.callback = callback
            window.overlay = "confirm"
        }
    }

    // сообщения ядра (ошибки порта, старт/стоп сессии) показываем в острове
    Connections {
        target: connManager
        function onErrorOccurred(message) { island.show(message, "", "red", "x") }
        function onSuccessOccurred(message) { island.show(message, appState.endpoint, "green", "check") }
        function onConnectionChanged(isConnected) {
            window.overlay = window.overlay === "appearance" ? "appearance" : ""
            if (isConnected) confettiBurst.fire()
        }
    }
    Connections {
        target: logManager
        function onErrorOccurred(message) { island.show(message, "", "red", "x") }
        function onSuccessOccurred(message) { island.show(message, "", "green", "check") }
    }

    // ── клавиши ──
    Shortcut { sequence: "Ctrl+F"; onActivated: window.overlay = window.overlay === "palette" ? "" : "palette" }
    Item {
        id: keys
        anchors.fill: parent
        focus: true
        Keys.onPressed: function (e) {
            if (e.key === Qt.Key_Escape) { window.overlay = ""; dock.fabOpen = false; e.accepted = true }
            else if (e.key >= Qt.Key_1 && e.key <= Qt.Key_6 && e.modifiers === Qt.NoModifier) {
                window.goTo(e.key - Qt.Key_1)
                e.accepted = true
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ── шапка (она же заголовок окна) ──
        Rectangle {
            id: header
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            z: 5
            color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.94)
            Behavior on color { ColorAnimation { duration: 300 } }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Theme.separator
                opacity: 0.35 + 0.65 * window.headerP
            }

            // перетаскивание окна и двойной клик = развернуть
            MouseArea {
                anchors.fill: parent
                onPressed: window.startSystemMove()
                onDoubleClicked: window.maximized ? window.showNormal() : window.showMaximized()
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 14
                spacing: 12

                // бренд
                RowLayout {
                    spacing: 10
                    Icon { name: "brand"; size: 32; color: Theme.accent }
                    Column {
                        spacing: 3
                        Text {
                            text: "ELM327"
                            color: Theme.label
                            font.family: Theme.fontFamily
                            font.pixelSize: 15
                            font.weight: Font.ExtraBold
                            font.letterSpacing: 0.9
                        }
                        Text {
                            text: "EMULATOR"
                            color: Theme.label2
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            font.letterSpacing: 2.2
                        }
                    }
                    Rectangle {
                        visible: window.width > 1180
                        Layout.leftMargin: 8
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: chip.width + 26
                        radius: 15
                        color: Theme.fill
                        Row {
                            id: chip
                            anchors.centerIn: parent
                            spacing: 8
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 7; height: 7; radius: 4
                                color: appState.connected ? Theme.green : Theme.gray
                            }
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: appState.connected ? appState.endpoint : qsTr("Offline")
                                color: appState.connected ? Theme.label : Theme.label2
                                font.family: Theme.monoFamily
                                font.pixelSize: 13
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // «Simulate drive»
                RowLayout {
                    spacing: 10
                    Text {
                        visible: window.width > 1360
                        text: qsTr("Simulate drive")
                        color: Theme.label2
                        font.family: Theme.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }
                    IosSwitch {
                        small: true
                        checked: appState.simulate
                        onToggled: function (c) { window.toggleSim(c) }
                    }
                }

                // поиск / палитра команд
                Rectangle {
                    Layout.preferredHeight: 36
                    Layout.preferredWidth: searchRow.width + 20
                    radius: 18
                    color: searchMouse.containsMouse ? Theme.fill2 : Theme.fill
                    scale: searchMouse.pressed ? 0.95 : 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }
                    Row {
                        id: searchRow
                        anchors.centerIn: parent
                        spacing: 8
                        Icon { anchors.verticalCenter: parent.verticalCenter; name: "search"; size: 16; color: Theme.label2 }
                        Text {
                            visible: window.width > 1300
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Search")
                            color: Theme.label2
                            font.family: Theme.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.Medium
                        }
                        Rectangle {
                            visible: window.width > 1300
                            anchors.verticalCenter: parent.verticalCenter
                            width: kbdT.implicitWidth + 14; height: 22; radius: 6
                            color: Theme.fill
                            Text { id: kbdT; anchors.centerIn: parent; text: "Ctrl F"; color: Theme.label2; font.family: Theme.monoFamily; font.pixelSize: 11 }
                        }
                    }
                    MouseArea {
                        id: searchMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: window.overlay = "palette"
                    }
                }

                // оформление
                Rectangle {
                    id: accBtn
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 18
                    color: accMouse.containsMouse ? Theme.fill2 : Theme.fill
                    scale: accMouse.pressed ? 0.88 : 1
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }
                    Rectangle {
                        anchors.centerIn: parent
                        width: 24; height: 24; radius: 12
                        color: Theme.tint(Theme.accent, 0.25)
                        Rectangle { anchors.centerIn: parent; width: 18; height: 18; radius: 9; color: Theme.accent }
                    }
                    MouseArea {
                        id: accMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: window.overlay = window.overlay === "appearance" ? "" : "appearance"
                    }
                }

                AppButton {
                    kind: appState.connected ? "red" : "filled"
                    iconName: appState.connected ? "stop" : "play"
                    text: appState.connected ? qsTr("Stop") : qsTr("Start")
                    onClicked: appState.requestToggle()
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 24; Layout.leftMargin: 4; Layout.rightMargin: 4; color: Theme.separator }

                // кнопки окна
                Repeater {
                    model: [
                        { act: "min", icon: "winMin" },
                        { act: "max", icon: window.maximized ? "winRestore" : "winMax" },
                        { act: "close", icon: "x" }
                    ]
                    delegate: Rectangle {
                        readonly property bool isClose: modelData.act === "close"
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 18
                        color: wm.containsMouse ? (isClose ? Theme.red : Theme.fill2) : "transparent"
                        scale: wm.pressed ? 0.88 : 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.56 } }
                        Icon {
                            anchors.centerIn: parent
                            name: modelData.icon
                            size: 18
                            color: wm.containsMouse && isClose ? "white" : Theme.label
                        }
                        MouseArea {
                            id: wm
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.act === "min") window.showMinimized()
                                else if (modelData.act === "max") window.maximized ? window.showNormal() : window.showMaximized()
                                else window.close()
                            }
                        }
                    }
                }
            }

            // компактный заголовок страницы появляется при прокрутке
            Text {
                anchors.centerIn: parent
                text: window.pageTitles[window.currentPage]
                color: Theme.label
                font.family: Theme.fontFamily
                font.pixelSize: 16
                font.weight: Font.DemiBold
                opacity: window.headerP
                transform: Translate { y: (1 - window.headerP) * 8 }
            }
        }

        // ── страницы ──
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: window.currentPage

            OverviewPage { id: pOverview; app: appState; onGoTo: function (i) { window.goTo(i) } }
            ConnectionPage { id: pConnection; app: appState }
            CardsPage { id: pParams; app: appState }
            AtPage { id: pAt; app: appState }
            LogsPage { id: pLogs; app: appState }
            DelayPage { id: pDelay; app: appState }
        }
    }

    // ── затемнение под быстрыми действиями ──
    Rectangle {
        anchors.fill: parent
        z: 55
        color: Theme.dark ? "#73000000" : "#59f2f2f7"
        opacity: dock.fabOpen ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 300 } }
        MouseArea { anchors.fill: parent; onClicked: dock.fabOpen = false }
    }

    // ── плавающая навигация ──
    Dock {
        id: dock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 22
        z: 60
        pages: window.pages
        currentIndex: window.currentPage
        logsBadge: appState.unread
        fabItems: [
            { id: "run", text: appState.connected ? qsTr("Stop server") : qsTr("Start server"), icon: appState.connected ? "stop" : "play", tone: appState.connected ? "red" : "green" },
            { id: "sc",  text: qsTr("Next scenario"), icon: ParamDefs.scenarioIcons[ParamDefs.scenarioOrder[(ParamDefs.scenarioOrder.indexOf(appState.scenario) + 1) % ParamDefs.scenarioOrder.length]], tone: "acc" },
            { id: "sim", text: appState.simulate ? qsTr("Simulate drive · on") : qsTr("Simulate drive · off"), icon: "car", tone: "blue" }
        ]
        onPicked: function (i) { window.goTo(i) }
        onFabPicked: function (id) {
            if (id === "run") appState.requestToggle()
            else if (id === "sc") window.nextScenario()
            else if (id === "sim") window.toggleSim(!appState.simulate)
        }
    }

    // ── Dynamic Island ──
    Island {
        id: island
        anchors.horizontalCenter: parent.horizontalCenter
        y: 10
        z: 70
        connected: appState.connected
        onToggleRequested: appState.requestToggle()
        onStatusRequested: window.statusToast()
    }

    // ── тосты ──
    ToastStack {
        id: toasts
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        z: 115
    }

    // ── конфетти при старте сервера ──
    Confetti { id: confettiBurst; anchors.fill: parent; z: 118 }

    // ── затемнение под оверлеями ──
    Rectangle {
        anchors.fill: parent
        z: 100
        color: "#6b000000"
        opacity: (window.overlay === "edit" || window.overlay === "ports" || window.overlay === "confirm" || window.overlay === "palette") ? 1 : 0
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 300 } }
        MouseArea { anchors.fill: parent; onClicked: window.overlay = "" }
    }

    // клик мимо окна оформления закрывает его
    MouseArea {
        anchors.fill: parent
        z: 105
        visible: window.overlay === "appearance"
        onClicked: window.overlay = ""
    }

    AppearancePopup {
        x: window.width - width - 24
        y: 72
        z: 110
        shown: window.overlay === "appearance"
    }

    CommandPalette {
        id: palette
        z: 125
        app: appState
        shown: window.overlay === "palette"
        onCloseRequested: window.overlay = ""
        commands: {
            var c = []
            c.push({ group: qsTr("Server"), title: appState.connected ? qsTr("Stop server") : qsTr("Start server"),
                     icon: appState.connected ? "stop" : "play", tone: appState.connected ? "red" : "green", kbd: "S",
                     run: function () { appState.requestToggle() } })
            c.push({ group: qsTr("Server"), title: qsTr("Toggle simulate drive"), icon: "car", tone: "blue",
                     run: function () { window.toggleSim(!appState.simulate) } })
            for (var i = 0; i < window.pages.length; ++i)
                c.push({ group: qsTr("Go to"), title: window.pageTitles[i], icon: window.pages[i].icon, tone: "gray", kbd: "" + (i + 1),
                         run: (function (n) { return function () { window.goTo(n) } })(i) })
            ParamDefs.scenarioOrder.forEach(function (n) {
                c.push({ group: qsTr("Scenario"), title: n, icon: ParamDefs.scenarioIcons[n], tone: "acc",
                         run: function () { appState.applyScenario(n) } })
            })
            ParamDefs.profileOrder.forEach(function (n) {
                c.push({ group: qsTr("Delay profile"), title: n, icon: ParamDefs.profileIcons[n], tone: "indigo",
                         run: function () { appState.applyProfile(n) } })
            })
            c.push({ group: qsTr("Logs"), title: qsTr("Clear logs"), icon: "trash", tone: "red",
                     run: function () { pLogs.clearWithConfirm() } })
            c.push({ group: qsTr("Logs"), title: qsTr("Export logs…"), icon: "download", tone: "teal",
                     run: function () { window.goTo(4); pLogs.exportLogs() } })
            c.push({ group: qsTr("Appearance"), title: Theme.dark ? qsTr("Light theme") : qsTr("Dark theme"), icon: Theme.dark ? "sun" : "moon", tone: "indigo", kbd: "T",
                     run: function () { Theme.dark = !Theme.dark } })
            ParamDefs.accents.forEach(function (a) {
                c.push({ group: qsTr("Appearance"), title: qsTr("Accent · %1").arg(a.n), icon: "palette", tone: a.c === "mono" ? "gray" : a.c,
                         run: function () { Theme.accentKey = a.c } })
            })
            return c
        }
    }

    EditSheet {
        id: editSheet
        z: 120
        app: appState
        shown: window.overlay === "edit"
        onCloseRequested: window.overlay = ""
    }

    PortSheet {
        z: 120
        app: appState
        shown: window.overlay === "ports"
        onCloseRequested: window.overlay = ""
    }

    ConfirmAlert {
        id: confirm
        z: 130
        shown: window.overlay === "confirm"
        onCloseRequested: window.overlay = ""
    }

    // ── рамка окна и ресайз за края ──
    Rectangle {
        anchors.fill: parent
        z: 200
        color: "transparent"
        border.width: window.maximized ? 0 : 1
        border.color: Theme.separator
        enabled: false
    }

    Repeater {
        model: [
            { e: Qt.LeftEdge, c: Qt.SizeHorCursor, l: true, t: false, r: false, b: false },
            { e: Qt.RightEdge, c: Qt.SizeHorCursor, l: false, t: false, r: true, b: false },
            { e: Qt.TopEdge, c: Qt.SizeVerCursor, l: false, t: true, r: false, b: false },
            { e: Qt.BottomEdge, c: Qt.SizeVerCursor, l: false, t: false, r: false, b: true },
            { e: Qt.LeftEdge | Qt.TopEdge, c: Qt.SizeFDiagCursor, l: true, t: true, r: false, b: false },
            { e: Qt.RightEdge | Qt.TopEdge, c: Qt.SizeBDiagCursor, l: false, t: true, r: true, b: false },
            { e: Qt.LeftEdge | Qt.BottomEdge, c: Qt.SizeBDiagCursor, l: true, t: false, r: false, b: true },
            { e: Qt.RightEdge | Qt.BottomEdge, c: Qt.SizeFDiagCursor, l: false, t: false, r: true, b: true }
        ]
        delegate: MouseArea {
            readonly property bool corner: (modelData.l || modelData.r) && (modelData.t || modelData.b)
            enabled: !window.maximized
            z: 210
            width: corner ? 12 : (modelData.l || modelData.r ? 6 : parent.width - 24)
            height: corner ? 12 : (modelData.t || modelData.b ? 6 : parent.height - 24)
            x: modelData.l ? 0 : (modelData.r ? parent.width - width : 12)
            y: modelData.t ? 0 : (modelData.b ? parent.height - height : 12)
            cursorShape: modelData.c
            onPressed: window.startSystemResize(modelData.e)
        }
    }
}
