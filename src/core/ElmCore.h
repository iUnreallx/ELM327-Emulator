#pragma once
#include <memory>
#include "interfaces/ITransport.h"
#include "pipeline/Router.h"

class ElmCore {
public:
    ElmCore();

    void setTransport(std::shared_ptr<ITransport> transport);

private:
    Router m_router;
    std::shared_ptr<ITransport> m_transport;
};
