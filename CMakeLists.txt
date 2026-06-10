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
        Qml/Main.qml

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



    RESOURCES
        qml/assets/fonts/Ubuntu-Bold.ttf
        qml/assets/fonts/Ubuntu-Regular.ttf
        readme.md
        .gitignore
        SOURCES src/core/pipeline/Preprocessor.h
        SOURCES src/core/pipeline/Preprocessor.cpp
        SOURCES src/core/pipeline/Formatter.cpp
        SOURCES src/core/pipeline/Formatter.h
        SOURCES src/core/EcuModel.cpp
        SOURCES src/core/EcuModel.h
)

set_target_properties(Elm327-Emulator PROPERTIES
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(Elm327-Emulator
    PRIVATE Qt6::Quick Qt6::SerialPort
)
