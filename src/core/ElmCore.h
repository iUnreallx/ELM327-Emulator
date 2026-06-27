#pragma once
#include <memory>
#include "interfaces/ITransport.h"
#include "pipeline/Router.h"
#include "DelayManager.h"

class ElmCore {
public:
    ElmCore();

    void setTransport(std::shared_ptr<ITransport> transport);

    /// колбек о потере соединения с транспортом.
    /// в данный момент управляет ConnectionManager.
    void setConnectionLostCallback(std::function<void()> callback);

    /// колбек отвечающий за логирование.
    /// ответсвенный так же ConnectionMngr
    using LogCallback = std::function<void(bool isRx, const QByteArray& msg)>;
    void setLogCallback(LogCallback callback);

    EcuState& getEcuState() {
        return m_router.getEcuState();
    }
    ElmConfig& getElmConfig() {
        return m_router.getElmConfig();
    }

    void setDelayManager(std::shared_ptr<DelayManager> manager);

private:
    Router m_router;
    std::shared_ptr<DelayManager> m_delayManager;
    std::shared_ptr<ITransport> m_transport;
    std::function<void()> m_onConnectionLost;
    LogCallback m_logCallback;
};
