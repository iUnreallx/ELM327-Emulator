#pragma once

#include "src/core/interfaces/ITransport.h"
#include <QObject>
#include <QSerialPort>
#include <QString>

class SerialTransport : public QObject, public ITransport
{
    Q_OBJECT

public:
    SerialTransport();
    ~SerialTransport() override;

    /// данные для настройки подключения
    /// к адаптеру по передаваеммым значениям
    void setPortName(const QString& portName);
    void setBaudRate(int baudRaute);

    /// наследование от itransport
    void setDataCallback(DataReceivedCallback callback) override;
    void setConnectionCallback(ConnectionChangedCallback callback) override;
    void write(const QByteArray& data) override;

    bool open() override;
    void close() override;
    bool isOpen() const override;

private slots:
    void handleReadyRead();
    void handleError(QSerialPort::SerialPortError error);

private:
    QSerialPort m_serialPort;

    DataReceivedCallback m_dataCallback;
    ConnectionChangedCallback m_connectionCallback;
};
