#pragma once
#include <QByteArray>
#include <functional>

class ITransport {
public:
    virtual ~ITransport() = default;

    /// Колбек для ядра вызываемый при получении байтов транспорта
    /// и передающий в ядро свои данные.
    using DataReceivedCallback = std::function<void(const QByteArray&)>;
    virtual void setDataCallback(DataReceivedCallback callback) = 0;

    virtual QString transportName() const = 0;

    /// запись данных в транспортный уровень
    virtual void write(const QByteArray &data) = 0;

    /// состояние транспорта в текущий момеент
    virtual bool open() = 0;
    virtual void close() = 0;
    virtual bool isOpen() const = 0;

    /// коллбек оповещающий о подключении.отключении
    using ConnectionChangedCallback = std::function<void(bool isConnected)>;
    virtual void setConnectionCallback(ConnectionChangedCallback callback) = 0;
};
