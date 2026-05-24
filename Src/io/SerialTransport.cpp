#include "SerialTransport.h"
#include <QDebug>

SerialTransport::SerialTransport() {
    connect(&m_serialPort, &QSerialPort::readyRead, this, &SerialTransport::handleReadyRead);
    connect(&m_serialPort, &QSerialPort::errorOccurred, this, &SerialTransport::handleError);
}

SerialTransport::~SerialTransport() {
    close();
}

void SerialTransport::setPortName(const QString& portName) {
    m_serialPort.setPortName(portName);
}

void SerialTransport::setBaudRate(int baudRate) {
    m_serialPort.setBaudRate(baudRate);
}

void SerialTransport::setDataCallback(DataReceivedCallback callback) {
    m_dataCallback = callback;
}

void SerialTransport::setConnectionCallback(ConnectionChangedCallback callback) {
    m_connectionCallback = callback;
}

bool SerialTransport::open() {
    if (m_serialPort.isOpen()) {
        qDebug() << "Порт уже открыт";
        return true;
    }

    if (m_serialPort.open(QIODevice::ReadWrite)) {
        if (m_connectionCallback) {
            m_connectionCallback(true);
        }
        return true;
    }

    qDebug() << "Не удалось открыть порт - " << m_serialPort.errorString();
    return false;
}

void SerialTransport::close() {
    if (m_serialPort.isOpen()) {
        m_serialPort.close();
        if (m_connectionCallback) {
            m_connectionCallback(false);
        }
    }
}

bool SerialTransport::isOpen() const {
    return m_serialPort.isOpen();
}

void SerialTransport::write(const QByteArray& data) {
    if (m_serialPort.isOpen()) {
        m_serialPort.write(data);
    }
}

void SerialTransport::handleReadyRead() {
    QByteArray rawData = m_serialPort.readAll();

    if (m_dataCallback) {
        m_dataCallback(rawData);
    }
}

void SerialTransport::handleError(QSerialPort::SerialPortError error) {
    if (error == QSerialPort::NoError) return;

    qDebug() << "Ошибка порта:" << m_serialPort.errorString();

    if (error == QSerialPort::ResourceError || error == QSerialPort::DeviceNotFoundError) {
        close();
    }
}
