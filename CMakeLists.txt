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
        Src/Source/SerialPortScanner.cpp
        Src/Source/SerialPortConnector.cpp
        Src/Source/SerialPortWorker.cpp
        Src/Header/SerialPortScanner.h
        Src/Header/SerialPortConnector.h
        Src/Header/SerialPortWorker.h

    RESOURCES
        Qml/assets/fonts/Ubuntu-Bold.ttf
        Qml/assets/fonts/Ubuntu-Regular.ttf
        readme.md
        .gitignore
)

set_target_properties(Elm327-Emulator PROPERTIES
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(Elm327-Emulator
    PRIVATE Qt6::Quick Qt6::SerialPort
)
