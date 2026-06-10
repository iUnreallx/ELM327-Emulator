#pragma once
#include <memory>
#include "interfaces/ITransport.h"
#include "pipeline/Router.h"

class ElmCore {
public:
    ElmCore();

    void setTransport(std::shared_ptr<ITransport> transport);

    EcuState& getEcuState() {
        return m_router.getEcuState();
    }
    ElmConfig& getElmConfig() {
        return m_router.getElmConfig();
    }

private:
    Router m_router;
    std::shared_ptr<ITransport> m_transport;
};
