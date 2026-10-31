#pragma once

#include <QObject>
#include <QString>
#include <memory>
#include <QPointer>
#include "ElmCore.h"

class ConnectionManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionChanged)
    Q_PROPERTY(bool connecting READ isConnecting NOTIFY connectingChanged)

public:
    explicit ConnectionManager(std::shared_ptr<ElmCore> core, QObject *parent = nullptr);

    bool isConnected() const;
    bool isConnecting() const;

    Q_INVOKABLE void toggleConnection(int mode, const QString& ip,
                                      const QString& port, const QString& comPort);

    Q_INVOKABLE QStringList getAvailablePorts() const;

signals:
    void connectionChanged(bool isConnected);
    void connectingChanged(bool connecting);
    void errorOccurred(const QString& msg);
    void successOccurred(const QString& msg);

private:
    void setConnected(bool state);
    void setConnecting(bool state);
    void finishSerialOpen(const QString& portName, bool probeOk, const QString& probeError);

    std::shared_ptr<ElmCore> m_core;

    bool m_isConnected = false;
    bool m_isConnecting = false;
};
