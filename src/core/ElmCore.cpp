#include "ElmCore.h"
#include <random>
#include <QTimer>
#include <QDebug>

ElmCore::ElmCore() {}

void ElmCore::setConnectionLostCallback(std::function<void()> callback) {
    m_onConnectionLost = callback;
}

void ElmCore::setConnectionGetCallback(std::function<void()> callback) {
    m_onConnectionGet = callback;
}

void ElmCore::setLogCallback(LogCallback callback) {
    m_logCallback = callback;
}

void ElmCore::setDelayManager(std::shared_ptr<DelayManager> manager) {
    m_delayManager = manager;
}

void ElmCore::setTransport(std::shared_ptr<ITransport> newTransport) {
    if (m_transport) {
        m_transport->setDataCallback(nullptr);
        m_transport->setConnectionCallback(nullptr);
        m_transport->close();
        m_isSessionGet = false;
    }

    QString previousTransport = "none";
    if (m_transport) {
        previousTransport = m_transport->transportName();
    }

    m_transport = newTransport;

    if (m_transport) {
        qDebug() << "новый транспорт установлен -> " << m_transport ->transportName();

        m_transport->setDataCallback([this] (const QByteArray &data) {
            if (m_logCallback) {
                /// rx
                m_logCallback(true, data);
            }

            QByteArray responce = m_router.routeIncomingData(data);

            if (!responce.isEmpty()) {
                if (m_onConnectionGet && !m_isSessionGet) {
                    m_onConnectionGet();
                }
                m_isSessionGet = true;

                int delayMs = 0;

                if (m_delayManager) {
                    delayMs = data.startsWith("AT") ? m_delayManager->atDelay() :
                                  m_delayManager->obdDelay();

                    int currentJitter = m_delayManager->jitter();

                    if (currentJitter > 0 && delayMs > 0) {
                        static std::mt19937 gen(std::random_device{}());
                        std::uniform_int_distribution<> dist(-currentJitter, currentJitter);

                        delayMs = std::max(0, delayMs + dist(gen));
                    }
                }

                if (delayMs > 0) {
                    QTimer::singleShot(delayMs, [this, responce]() {
                        if (m_transport) {
                            m_transport->write(responce);
                            if (m_logCallback) {
                                /// tx
                                m_logCallback(false, responce);
                            }
                        }
                    });
                } else {
                    m_transport->write(responce);
                    if (m_logCallback) {
                        /// tx
                        m_logCallback(false, responce);
                    }
                }
            }
        });

        m_transport->setConnectionCallback([this](bool isConnected) {
            if (isConnected) {
                qDebug() << "соединение установлено. эмуляция готова";

            } else {
                qDebug() << "связь разорвана";
                if (m_onConnectionLost) {
                    m_onConnectionLost();
                    m_isSessionGet = false;
                }
            }
        });

    } else {
         qDebug() << "транспорт " << previousTransport << " сброшен";
    }
}

