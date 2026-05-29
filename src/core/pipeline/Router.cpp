#include "src/core/pipeline/Router.h"
#include <QDebug>

Router::Router() {}

QByteArray Router::routeIncomingData(const QByteArray& rawData) {

    /// devide this place to Preprocessor.h .cpp file
    QString request = QString::fromUtf8(rawData).trimmed().toUpper();
    request.replace(" ", "");

    qDebug() << "получили запрос от транспорта: " << request;

    // bring out of the logick
    if (request.startsWith("AT")) {
        qDebug() << "обработка at команды";
        if (request == "ATZ") {
            return "ELM327 v1.5\r\n>";
        }
        return "OK\r\n>";
    }
    else if (request.startsWith("01")) {
        if (request == "010C") {
            qDebug() << "запрос оборотов";
            return "41 0C 0B B8\r\n>";
        }
    }

    //formater work in future

    return "?\r\n>";
}
