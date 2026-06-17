#pragma once

#include <QObject>
#include <QString>
#include <memory>
#include "ElmCore.h"

class ConnectionManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionChanged)

public:
    explicit ConnectionManager(std::shared_ptr<ElmCore> core, QObject *parent = nullptr);

    bool isConnected() const;

    Q_INVOKABLE void toggleConnection(int mode, const QString& ip,
                                      const QString& port, const QString& comPort);

    Q_INVOKABLE QStringList getAvailablePorts() const;

signals:
    void connectionChanged(bool isConnected);
    void errorOccurred(const QString& msg);
    void successOccurred(const QString& msg);

private:
    void setConnected(bool state);

    std::shared_ptr<ElmCore> m_core;

    bool m_isConnected = false;
};
