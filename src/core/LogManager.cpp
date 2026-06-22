#include "LogManager.h"
#include <QTime>
#include <QFile>
#include <QTextStream>
#include <QUrl>

LogManager::LogManager(std::shared_ptr<ElmCore> core, QObject *parent)
    : QObject(parent), m_core(core) {

    m_core->setLogCallback([this](bool isRx, const QByteArray& msg) {
        if (m_isLogPaused) return;

        QString text = QString::fromUtf8(msg).trimmed();

        text.replace("\r\n", " ");
        text.replace("\r", " ");
        text.replace(">", "");

        if (text.isEmpty()) return;

        QString timestamp = QTime::currentTime().toString("HH:mm:ss.zzz");

        QString logLine = QString("[%1] %2 -> %3")
                              .arg(timestamp)
                              .arg(isRx ? "RX" : "TX")
                              .arg(text);

        m_logBuffer.append(logLine);

        if (m_logBuffer.size() > MAX_LOG_LINES) {
            m_logBuffer.removeFirst();
        }

        emit logsAdded(isRx, text, timestamp);
    });
}

void LogManager::setLogPaused(bool isPause) {
    if (m_isLogPaused != isPause) {
        m_isLogPaused = isPause;
        emit logPausedChanged();
        if (m_isLogPaused) {
             emit successOccurred("Логирование поставлено на паузу!");
        } else {
             emit successOccurred("Логирование включено!");
        }
    }
}

void LogManager::clearLogs() {
    m_logBuffer.clear();
    emit logsCleared();
    emit successOccurred("Логи успешно очищены!");
}

bool LogManager::exportLogs(const QString& path) {
    if (m_logBuffer.isEmpty()) {
        emit errorOccurred("Буфер логов пуст, экспортировать нечего.");
        return false;
    }

    QUrl url(path);
    QString localPath = url.isLocalFile() ? url.toLocalFile() : path;

    QFile file(localPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        emit errorOccurred("Не удалось создать или открыть файл для экспорта.");
        return false;
    }

    QTextStream out(&file);
    for (const QString& line : m_logBuffer) {
        out << line << "\n";
    }

    emit successOccurred("Логи успешно экспортированы!");
    return true;
}
