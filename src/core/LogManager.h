#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <memory>
#include "ElmCore.h"

class LogManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isLogPaused READ isLogPaused WRITE setLogPaused NOTIFY logPausedChanged)

public:
    explicit LogManager(std::shared_ptr<ElmCore> core, QObject *parent = nullptr);

    Q_INVOKABLE void clearLogs();
    Q_INVOKABLE bool exportLogs(const QString& path);

    bool isLogPaused() const {
        return m_isLogPaused;
    }
    void setLogPaused(bool isPause);

signals:
    void logPausedChanged();
    void logsCleared();
    void logsAdded(bool isRx, const QString& msg, const QString& timestamp);

    /// Сигналы для тостов в ui
    void errorOccurred(const QString& msg);
    void successOccurred(const QString& msg);

private:
    std::shared_ptr<ElmCore> m_core;

    QStringList m_logBuffer;
    const int MAX_LOG_LINES = 1000;
    bool m_isLogPaused = false;
};
