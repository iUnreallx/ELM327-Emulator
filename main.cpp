#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "src/core/ElmCore.h"
#include "src/core/EcuModel.h"
#include "src/core/ConnectionManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    QCoreApplication::setOrganizationName("OpenSource.foundation");
    QCoreApplication::setOrganizationDomain("github-iUnreallx.com");
    QCoreApplication::setApplicationName("Elm327-Emulator");

    auto core = std::make_shared<ElmCore>();
    auto ecuModel = std::make_shared<EcuModel>(&core->getEcuState());

    auto connectionManager = std::make_shared<ConnectionManager>(core);

    engine.rootContext()->setContextProperty("ecuModel", ecuModel.get());
    engine.rootContext()->setContextProperty("connManager", connectionManager.get());

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
