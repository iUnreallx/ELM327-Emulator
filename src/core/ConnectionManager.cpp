#include "ConnectionManager.h"
#include "../io/SerialTransport.h"
#include <QSerialPortInfo>
#include <QDebug>
#include <QTime>
#include <QFile>
#include <QTextStream>
#include <QUrl>
#include <QSerialPort>
#include <QPointer>
#include <thread>

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

bool ConnectionManager::isConnecting() const {
    return m_isConnecting;
}

void ConnectionManager::setConnecting(bool state) {
    if (m_isConnecting != state) {
        m_isConnecting = state;
        emit connectingChanged(m_isConnecting);
    }
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

    if (m_isConnecting) {
        return;
    }

    if (mode == 2 || mode == 1) {
        if (comPort.isEmpty()) {
            emit errorOccurred("Укажите имя COM порта!");
            return;
        }

        const QString mainComPort = comPort.trimmed().toUpper();

        // Открытие порта (особенно Bluetooth) может блокироваться на секунды,
        // поэтому пробуем открыть его в фоновом потоке, чтобы интерфейс не вис.
        setConnecting(true);
        QPointer<ConnectionManager> self(this);
        std::thread([self, mainComPort]() {
            QSerialPort probe;
            probe.setPortName(mainComPort);
            probe.setBaudRate(38400);
            const bool ok = probe.open(QIODevice::ReadWrite);
            const QString err = ok ? QString() : probe.errorString();
            if (ok) {
                probe.close();
            }
            if (!self) {
                return;
            }
            QMetaObject::invokeMethod(self.data(), [self, mainComPort, ok, err]() {
                if (self) {
                    self->finishSerialOpen(mainComPort, ok, err);
                }
            }, Qt::QueuedConnection);
        }).detach();
    }

    else if (mode == 0) { // Wi-Fi
        emit errorOccurred("TCP сервер для Wi-Fi еще в разработке.");
    }
}


void ConnectionManager::finishSerialOpen(const QString& portName, bool probeOk, const QString& probeError) {
    if (!probeOk) {
        setConnecting(false);
        qDebug() << "Не удалось открыть порт - " << probeError;
        emit errorOccurred("Не удалось открыть порт: " + portName);
        return;
    }

    // Драйвер уже ответил при пробном открытии, поэтому повторное открытие быстрое.
    auto serialTransport = std::make_shared<SerialTransport>();
    serialTransport->setPortName(portName);
    serialTransport->setBaudRate(38400);

    m_core->setTransport(serialTransport);
    const bool opened = serialTransport->open();
    setConnecting(false);

    if (opened) {
        setConnected(true);
        emit successOccurred("Успешное подключение: " + serialTransport->transportName());
    } else {
        emit errorOccurred("Не удалось открыть порт: " + portName);
    }
}
