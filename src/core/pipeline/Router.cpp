#include "src/core/pipeline/Router.h"
#include "../commands/AtCommandHandler.h"
#include "../commands/ObdCommandHandler.h"
#include "Preprocessor.h"
#include "Formatter.h"
#include <QDebug>

Router::Router() {}

QByteArray Router::routeIncomingData(const QByteArray& rawData) {
    /// логика приведения всей строки полученных байт к одному стилю
    QString request = Preprocessor::cleanRequest(rawData);
    qDebug() << "получили запрос от транспорта: " << request;


    /// парсинг запроса и преобразоваие
    /// его в ответ от классов
    QString nakedResponse = "?";

    if (request.startsWith("AT")) {
        nakedResponse = AtCommandHandler::handle(request, m_elmConfig);
    }

    else if (request.startsWith("01")) {
        nakedResponse = ObdCommandHandler::handle(request, m_ecuState);
    }

    /// форматирование ответа от двигателя к единному стилю
    QByteArray response = Formatter::formatResponse(
        nakedResponse, request, m_elmConfig);
    qDebug() << "ответ движка нашего: " << response;

    return response;
}
