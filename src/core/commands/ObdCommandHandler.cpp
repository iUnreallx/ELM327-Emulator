#include "ObdCommandHandler.h"

#include <array>
#include <QtGlobal>

namespace
{

    constexpr std::array<int, 5> supportedPids = {
        0x04, // Calculated Engine Load
        0x05, // Engine Coolant Temperature
        0x0C, // Engine RPM
        0x0D, // Vehicle Speed
        0x11  // Throttle Position
    };

    QString byteToHex(int value)
    {
        return QString("%1")
        .arg(value, 2, 16, QChar('0'))
            .toUpper();
    }

    QString supportedPidsResponse()
    {
        quint32 mask = 0;

        for (int pid : supportedPids)
        {
            if (pid >= 0x01 && pid <= 0x20)
            {
                mask |= quint32(1) << (0x20 - pid);
            }
        }

        return "4100" +
               QString("%1")
                   .arg(mask, 8, 16, QChar('0'))
                   .toUpper();
    }

    int percentToRawByte(int percent)
    {
        const int clampedPercent = qBound(0, percent, 100);

        return qRound(
            static_cast<double>(clampedPercent) * 255.0 / 100.0
        );
    }

}

QString ObdCommandHandler::handle(
    const QString& request,
    const EcuState& state
    )
{
    if (!request.startsWith("01") || request.length() < 4)
        return "?";

    const QString pid = request.mid(2, 2);

    // список поддерживаемых параметров 1-20.
    if (pid == "00")
    {
        return supportedPidsResponse();
    }

    // нагрузка на двигатель
    if (pid == "04")
    {
        const int rawLoad = percentToRawByte(state.engineLoad);

        return "4104" + byteToHex(rawLoad);
    }

    // температура двигателя
    if (pid == "05")
    {
        const int temperature =
            qBound(-40, state.coolantTemp, 215);

        return "4105" + byteToHex(temperature + 40);
    }

    // обороты двигателя
    if (pid == "0C")
    {
        const int rpm = qBound(0, state.rpm, 16383);
        const int rawRpm = rpm * 4;

        return "410C" +
               QString("%1")
                   .arg(rawRpm, 4, 16, QChar('0'))
                   .toUpper();
    }

    // скорость транспорта
    if (pid == "0D")
    {
        const int speed = qBound(0, state.speed, 255);

        return "410D" + byteToHex(speed);
    }

    // положение. дроссельной заслонки
    if (pid == "11")
    {
        const int rawThrottle =
            percentToRawByte(state.throttlePosition);

        return "4111" + byteToHex(rawThrottle);
    }

    return "NO DATA";
}
