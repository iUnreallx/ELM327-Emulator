#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "src/core/ElmCore.h"
#include "src/io/SerialTransport.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    QCoreApplication::setOrganizationName("OpenSource.foundation");
    QCoreApplication::setOrganizationDomain("github-iUnreallx.com");
    QCoreApplication::setApplicationName("Elm327-Emulator");

    auto core = std::make_shared<ElmCore>();

    auto serialTransport = std::make_shared<SerialTransport>();

    serialTransport->setPortName("COM6");

    if (serialTransport->open()) {
        qDebug() << "Порт открыт";

        core->setTransport(serialTransport);
    } else {
        qDebug() << "ошибк";
        return -1;
    }

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
