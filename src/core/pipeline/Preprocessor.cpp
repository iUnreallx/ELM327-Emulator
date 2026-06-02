#include "Preprocessor.h"

QString Preprocessor::cleanRequest(const QByteArray& rawData) {
    QString request = QString::fromUtf8(rawData).trimmed().toUpper();
    request.replace(" ", "");
    return request;
}
