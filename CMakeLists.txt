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
        qml/pages/OverviewPage.qml
        qml/components/SparklineGraph.qml

    SOURCES

        src/core/interfaces/ITransport.h
        src/core/pipeline/Router.cpp
        src/core/pipeline/Router.h
        src/core/state/ElmConfig.h
        src/core/state/EcuState.h
        src/core/ElmCore.cpp
        src/core/ElmCore.h

        src/io/SerialTransport.cpp
        src/io/SerialTransport.h

        src/core/commands/AtCommandHandler.cpp
        src/core/commands/AtCommandHandler.h
        src/core/commands/ObdCommandHandler.cpp
        src/core/commands/ObdCommandHandler.h

        src/core/pipeline/Preprocessor.h
        src/core/pipeline/Preprocessor.cpp
        src/core/pipeline/Formatter.cpp
        src/core/pipeline/Formatter.h
        src/core/EcuModel.cpp
        src/core/EcuModel.h



    RESOURCES
        qml/assets/fonts/Ubuntu-Bold.ttf
        qml/assets/fonts/Ubuntu-Regular.ttf
        readme.md
        .gitignore
        QML_FILES qml/components/ParameterCard.qml
        QML_FILES qml/components/ConnectionPanel.qml
        SOURCES src/core/ConnectionManager.h
        SOURCES src/core/ConnectionManager.cpp

)

set_target_properties(Elm327-Emulator PROPERTIES
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(Elm327-Emulator
    PRIVATE Qt6::Quick Qt6::SerialPort
)
