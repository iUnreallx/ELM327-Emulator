#include "ElmCore.h"
#include <QDebug>

ElmCore::ElmCore() {}

void ElmCore::setConnectionLostCallback(std::function<void()> callback) {
    m_onConnectionLost = callback;
}

void ElmCore::setTransport(std::shared_ptr<ITransport> newTransport) {
    if (m_transport) {
        m_transport->setDataCallback(nullptr);
        m_transport->setConnectionCallback(nullptr);
        m_transport->close();
    }

    QString previousTransport = "none";
    if (m_transport) {
        previousTransport = m_transport->transportName();
    }

    m_transport = newTransport;

    if (m_transport) {
        qDebug() << "новый транспорт установлен -> " << m_transport ->transportName();

        m_transport->setDataCallback([this] (const QByteArray &data) {
            QByteArray responce = m_router.routeIncomingData(data);

            if (!responce.isEmpty()) {
                m_transport->write(responce);
            }
        });

        m_transport->setConnectionCallback([this](bool isConnected) {
            if (isConnected) {
                qDebug() << "соединение установлено. эмуляция готова";

            } else {
                qDebug() << "связь разорвана";
                if (m_onConnectionLost) {
                    m_onConnectionLost();
                }
            }
        });
    } else {
         qDebug() << "транспорт " << previousTransport << " сброшен";
    }
}

