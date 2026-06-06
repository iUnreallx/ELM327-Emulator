#pragma once

#include <QString>
#include "../state/ElmConfig.h"

class AtCommandHandler {
public:
    static QString handle(const QString& request, ElmConfig& config);
};
