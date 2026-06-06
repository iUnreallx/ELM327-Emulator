#include "ObdCommandHandler.h"

QString ObdCommandHandler::handle(const QString& request, const EcuState& state) {
    if (!request.startsWith("01") || request.length() < 4) {
        return "?";
    }

    QString pid = request.mid(2, 2);

    /// скорость
    if (pid == "0D") {
        QString hexSpeed = QString("%1").arg(state.speed, 2, 16, QChar('0')).toUpper();
        return "410D" + hexSpeed;
    }

    /// обороты
    if (pid == "0C") {
        int rawRpm = state.rpm * 4;
        QString hexRpm = QString("%1").arg(rawRpm, 4, 16, QChar('0')).toUpper();
        return "410C" + hexRpm;
    }

    /// температура охлаждайки
    if (pid == "05") {
        int rawTemp = state.coolantTemp + 40;
        QString hexTemp = QString("%1").arg(rawTemp, 2, 16, QChar('0')).toUpper();
        return "4105" + hexTemp;
    }

    return "NO DATA";
}
