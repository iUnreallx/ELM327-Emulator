#pragma once

#include <QByteArray>
#include <QString>

class Preprocessor{
public:
    static QString cleanRequest(const QByteArray& rawData);
};
