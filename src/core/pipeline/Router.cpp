#include "src/core/pipeline/Router.h"
#include "Preprocessor.h"
#include "Formatter.h"
#include <QDebug>

Router::Router() {}

QByteArray Router::routeIncomingData(const QByteArray& rawData) {
    /// логика приведения всей строки полученных байт к одному стилю
    QString request = Preprocessor::cleanRequest(rawData);
    qDebug() << "получили запрос от транспорта: " << request;

    // todotodotodotodo
    QString nakedResponse = "";
    if (request.startsWith("AT")) {
        if (request == "ATZ") {
            nakedResponse = "ELM327 v1.5";
        } else {
            nakedResponse = "OK";
        }
    }

    else if (request.startsWith("01")) {
        if (request == "010D") {
            nakedResponse = "410D31";
        }
    }

    /// форматирование ответа от двигателя к единному стилю
    QByteArray response = Formatter::formatResponse(
        nakedResponse, request, m_elmConfig);
    qDebug() << "ответ движка нашего: " << response;

    return response;
}
