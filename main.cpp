#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <Src/Header/SerialPortScanner.h>
#include <Src/Header/SerialPortConnector.h>


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    QCoreApplication::setOrganizationName("OpenSource.foundation");
    QCoreApplication::setOrganizationDomain("github-iUnreallx.com");
    QCoreApplication::setApplicationName("Elm327-Emulator");

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
    );
    engine.loadFromModule("Elm327-Emulator", "Main");



    return app.exec();
}
