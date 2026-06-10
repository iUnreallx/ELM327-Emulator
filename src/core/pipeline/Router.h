#pragma once

#include <QByteArray>
#include "src/core/state/ElmConfig.h"
#include "src/core/state/EcuState.h"

class Router {
public:
    Router();

    QByteArray routeIncomingData(const QByteArray &data);

    EcuState& getEcuState() {
        return m_ecuState;
    }
    ElmConfig& getElmConfig() {
        return m_elmConfig;
    }

private:
    EcuState m_ecuState;
    ElmConfig m_elmConfig;
};
