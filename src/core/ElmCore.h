#pragma once
#include <memory>
#include "interfaces/ITransport.h"
#include "pipeline/Router.h"
#include "DelayManager.h"

class ElmCore {
public:
    ElmCore();

    /// меняем транспортный слой ( bluetooth / wifi и тд )
    void setTransport(std::shared_ptr<ITransport> transport);

    /// задержка отправки соообщений
    /// отвечает delayManager
    void setDelayManager(std::shared_ptr<DelayManager> manager);

    /// колбек о потере соединения с транспортом.
    /// в данный момент управляет ConnectionManager.
    void setConnectionLostCallback(std::function<void()> callback);
    void setConnectionGetCallback(std::function<void()> callback);

    /// колбек отвечающий за логирование.
    /// ответсвенный log manager
    using LogCallback = std::function<void(bool isRx, const QByteArray& msg)>;
    void setLogCallback(LogCallback callback);

    EcuState& getEcuState() {
        return m_router.getEcuState();
    }
    ElmConfig& getElmConfig() {
        return m_router.getElmConfig();
    }

private:
    Router m_router;
    LogCallback m_logCallback;
    std::shared_ptr<DelayManager> m_delayManager;
    std::shared_ptr<ITransport> m_transport;
    std::function<void()> m_onConnectionLost;
    std::function<void()> m_onConnectionGet;
    bool m_isSessionGet = false;
};
