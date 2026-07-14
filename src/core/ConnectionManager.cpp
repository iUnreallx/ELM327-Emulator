#include "ConnectionManager.h"
#include "../io/SerialTransport.h"
#include <QSerialPortInfo>
#include <QDebug>
#include <QTime>
#include <QFile>
#include <QTextStream>
#include <QUrl>

ConnectionManager::ConnectionManager(std::shared_ptr<ElmCore> core, QObject *parent) :
    QObject(parent), m_core(core) {

    m_core->setConnectionLostCallback([this]() {
        m_core->setTransport(nullptr);
        setConnected(false);
        emit errorOccurred("Связь с портом неожиданно потеряна!");
    });

    m_core->setConnectionGetCallback([this]() {
        emit successOccurred("Стартуем сессию!");
    });

}

QStringList ConnectionManager::getAvailablePorts() const {
    QStringList ports;

    for (const QSerialPortInfo &info : QSerialPortInfo::availablePorts()) {
        ports << info.portName();
    }

    return ports;
}

bool ConnectionManager::isConnected() const {
    return m_isConnected;
}

void ConnectionManager::setConnected(bool state) {
    if (m_isConnected != state) {
        m_isConnected = state;
        emit connectionChanged(m_isConnected);
    }
}

void ConnectionManager::toggleConnection(
    int mode, const QString& ip,
    const QString& port, const QString& comPort
        ) {

    if (m_isConnected) {
        m_core->setTransport(nullptr);
        setConnected(false);
        emit successOccurred("Эмуляции прекращена.");
        return;
    }

    if (mode == 2 || mode == 1) {
        if (comPort.isEmpty()) {
            emit errorOccurred("Укажите имя COM порта!");
            return;
        }

        auto serialTransport = std::make_shared<SerialTransport>();

        QString mainComPort = comPort.trimmed().toUpper();

        serialTransport -> setPortName(mainComPort);
        serialTransport -> setBaudRate(38400);

        m_core->setTransport(serialTransport);
        if (serialTransport->open()) {

            setConnected(true);

            QString succesConnectionMsg = "Успешное подключение: " + serialTransport->transportName();

            emit successOccurred(succesConnectionMsg);
        } else {
            emit errorOccurred("Не удалось открыть порт: " + mainComPort);
        }
    }

    else if (mode == 0) { // Wi-Fi
        emit errorOccurred("TCP сервер для Wi-Fi еще в разработке.");
    }
}

