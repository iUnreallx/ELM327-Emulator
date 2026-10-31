cmake_minimum_required(VERSION 3.16)

project(Elm327-Emulator VERSION 1.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick SerialPort)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(Elm327-Emulator
    main.cpp
)

set_source_files_properties(
    qml/components/Theme.qml
    qml/components/ParamDefs.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(Elm327-Emulator
    URI Elm327-Emulator
    VERSION 1.0

    QML_FILES
        qml/Main.qml
        qml/AppState.qml

        qml/components/AppButton.qml
        qml/components/AppSlider.qml
        qml/components/CommandPalette.qml
        qml/components/Confetti.qml
        qml/components/FloatField.qml
        qml/components/MiniChip.qml
        qml/components/Odo.qml
        qml/components/ScenarioChip.qml
        qml/components/SlideConfirm.qml
        qml/components/ToastStack.qml
        qml/components/VerticalTile.qml
        qml/components/AppearancePopup.qml
        qml/components/Badge.qml
        qml/components/Caption.qml
        qml/components/Cell.qml
        qml/components/ConfirmAlert.qml
        qml/components/Dock.qml
        qml/components/EditSheet.qml
        qml/components/Gauge.qml
        qml/components/Group.qml
        qml/components/Icon.qml
        qml/components/IosSwitch.qml
        qml/components/Island.qml
        qml/components/LogView.qml
        qml/components/PageBase.qml
        qml/components/PageHeader.qml
        qml/components/Panel.qml
        qml/components/ParamControl.qml
        qml/components/ParamDefs.qml
        qml/components/PortSheet.qml
        qml/components/RoundButton.qml
        qml/components/SearchField.qml
        qml/components/Segmented.qml
        qml/components/StatCard.qml
        qml/components/StatusIcon.qml
        qml/components/Stepper.qml
        qml/components/Theme.qml
        qml/components/ThemedScrollBar.qml

        qml/pages/OverviewPage.qml
        qml/pages/AtPage.qml
        qml/pages/ConnectionPage.qml
        qml/pages/CardsPage.qml
        qml/pages/LogsPage.qml
        qml/pages/DelayPage.qml
        qml/pages/DtcPage.qml
        qml/pages/SettingsPage.qml

    SOURCES
        src/core/ElmCore.cpp
        src/core/ElmCore.h

        src/core/EcuModel.cpp
        src/core/EcuModel.h

        src/core/ConnectionManager.cpp
        src/core/ConnectionManager.h

        src/core/LogManager.cpp
        src/core/LogManager.h

        src/core/DelayManager.cpp
        src/core/DelayManager.h

        src/core/interfaces/ITransport.h

        src/core/state/ElmConfig.h
        src/core/state/EcuState.h

        src/core/commands/AtCommandHandler.cpp
        src/core/commands/AtCommandHandler.h
        src/core/commands/ObdCommandHandler.cpp
        src/core/commands/ObdCommandHandler.h

        src/core/pipeline/Preprocessor.cpp
        src/core/pipeline/Preprocessor.h
        src/core/pipeline/Router.cpp
        src/core/pipeline/Router.h
        src/core/pipeline/Formatter.cpp
        src/core/pipeline/Formatter.h

        src/io/SerialTransport.cpp
        src/io/SerialTransport.h

    RESOURCES
        qml/components/qmldir
        qml/assets/fonts/Ubuntu-Bold.ttf
        qml/assets/fonts/Ubuntu-Regular.ttf
        qml/assets/fonts/Inter-Regular.ttf
        qml/assets/fonts/Inter-Medium.ttf
        qml/assets/fonts/Inter-SemiBold.ttf
        qml/assets/fonts/Inter-Bold.ttf
        qml/assets/fonts/Inter-ExtraBold.ttf

        qml/assets/sidebar/logo.png

        qml/assets/icons/activity.svg
        qml/assets/icons/alert.svg
        qml/assets/icons/arrowUp.svg
        qml/assets/icons/bolt.svg
        qml/assets/icons/brand.svg
        qml/assets/icons/bt.svg
        qml/assets/icons/car.svg
        qml/assets/icons/check.svg
        qml/assets/icons/chevD.svg
        qml/assets/icons/chevR.svg
        qml/assets/icons/copy.svg
        qml/assets/icons/doc.svg
        qml/assets/icons/download.svg
        qml/assets/icons/flame.svg
        qml/assets/icons/gauge.svg
        qml/assets/icons/hourglass.svg
        qml/assets/icons/info.svg
        qml/assets/icons/json.svg
        qml/assets/icons/list.svg
        qml/assets/icons/load.svg
        qml/assets/icons/minus.svg
        qml/assets/icons/moon.svg
        qml/assets/icons/overview.svg
        qml/assets/icons/palette.svg
        qml/assets/icons/pause.svg
        qml/assets/icons/pin.svg
        qml/assets/icons/play.svg
        qml/assets/icons/plug.svg
        qml/assets/icons/plus.svg
        qml/assets/icons/power.svg
        qml/assets/icons/reset.svg
        qml/assets/icons/sc-city.svg
        qml/assets/icons/sc-highway.svg
        qml/assets/icons/sc-idle.svg
        qml/assets/icons/sc-overheat.svg
        qml/assets/icons/sc-redline.svg
        qml/assets/icons/search.svg
        qml/assets/icons/sliders.svg
        qml/assets/icons/sparkle.svg
        qml/assets/icons/stop.svg
        qml/assets/icons/sun.svg
        qml/assets/icons/swap.svg
        qml/assets/icons/temp.svg
        qml/assets/icons/terminal.svg
        qml/assets/icons/throttle.svg
        qml/assets/icons/timer.svg
        qml/assets/icons/trash.svg
        qml/assets/icons/usb.svg
        qml/assets/icons/wifi.svg
        qml/assets/icons/winMax.svg
        qml/assets/icons/winMin.svg
        qml/assets/icons/winRestore.svg
        qml/assets/icons/x.svg

        qml/assets/logsPanel/play.svg
        qml/assets/logsPanel/pause.svg
        qml/assets/logsPanel/clear.svg
        qml/assets/logsPanel/export.svg

        qml/assets/connectionPanel/info.svg

        qml/assets/parametersCard/engine.svg
        qml/assets/parametersCard/speed.svg
        qml/assets/parametersCard/temp.svg
        qml/assets/parametersCard/voltage.svg

        readme.md
        .gitignore
)

set_target_properties(Elm327-Emulator PROPERTIES
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(Elm327-Emulator
    PRIVATE Qt6::Quick Qt6::SerialPort
)
