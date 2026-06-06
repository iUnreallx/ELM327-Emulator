#pragma once

#include <QString>
#include "../state/EcuState.h"

class ObdCommandHandler {
public:
    static QString handle(const QString& request, const EcuState& state);
};
