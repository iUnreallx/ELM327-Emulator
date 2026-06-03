#pragma once
#include <QByteArray>
#include <QString>
#include "../state/ElmConfig.h"

class Formatter {
public:
    static QByteArray formatResponse(
        const QString& engineResponce,
        const QString& request,
        const ElmConfig& config
        );
};
