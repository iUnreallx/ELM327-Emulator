cmake_minimum_required(VERSION 3.16)

project(Obd2-Emulator VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick SerialPort)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appObd2-Emulator
    main.cpp
)

qt_add_qml_module(appObd2-Emulator
    URI Obd2-Emulator
    VERSION 1.0

    QML_FILES
        Qml/Main.qml



    SOURCES
        Src/Source/SerialPortScanner.cpp
        Src/Source/SerialPortConnector.cpp
        Src/Source/SerialPortWorker.cpp
        Src/Source/logger/OBD_Logger.cpp
        Src/Header/SerialPortScanner.h
        Src/Header/SerialPortConnector.h
        Src/Header/SerialPortWorker.h
        Src/Header/logger/OBD_Logger.h

    RESOURCES
        Qml/assets/fonts/Ubuntu-Bold.ttf
        Qml/assets/fonts/Ubuntu-Regular.ttf
        readme.md


)



# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appObd2-Emulator PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appObd2-Emulator
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appObd2-Emulator
    PRIVATE Qt6::Quick Qt6::SerialPort
)

include(GNUInstallDirs)
install(TARGETS appObd2-Emulator
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
