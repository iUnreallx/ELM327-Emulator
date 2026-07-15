cmake_minimum_required(VERSION 3.16)

project(Elm327-Emulator VERSION 0.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick SerialPort)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(Elm327-Emulator
    main.cpp
)

qt_add_qml_module(Elm327-Emulator
    URI Elm327-Emulator
    VERSION 1.0

    QML_FILES
        qml/Main.qml

        qml/components/SidebarButton.qml
        qml/components/SparklineGraph.qml
        qml/components/ParameterCard.qml
        qml/components/ConnectionPanel.qml
        qml/components/LogsPanel.qml
        qml/components/ToastNotification.qml

        qml/pages/OverviewPage.qml
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
        qml/assets/fonts/Ubuntu-Bold.ttf
        qml/assets/fonts/Ubuntu-Regular.ttf

        qml/assets/sidebar/logo.png

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
