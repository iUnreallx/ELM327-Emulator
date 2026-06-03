#include "ElmCore.h"
#include <QDebug>

ElmCore::ElmCore() {}

void ElmCore::setTransport(std::shared_ptr<ITransport> newTransport) {
    if (m_transport) {
        m_transport->setDataCallback(nullptr);
        m_transport->setConnectionCallback(nullptr);
        m_transport->close();
    }

    m_transport = newTransport;
    qDebug() << "новый транспорт установлен";

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
        }
    });
}

