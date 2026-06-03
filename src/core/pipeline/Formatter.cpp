#include "Formatter.h"

QByteArray Formatter::formatResponse(
    const QString& engineResponce,
    const QString& request,
    const ElmConfig& config
) {
    QString result = "";

    /// AT L1 / AT L0.
    /// Включёл ли перенос строки или нет
    QString lineEnd = config.linefeedsEnabled ? "\r\n" : "\r";

    /// проверка на эхо, если есть то возвращаем полную
    /// строку запроса (requets) + сам наш формированный ответ ниже
    if (config.echoEnabled && !request.isEmpty()) {
        result = request + lineEnd;
    }

    /// если есть пробелы и запрос от нашей ситсемы не пуст
    /// идёт проверка на hex строку ( то есть ответ закодированной цифры )
    /// и в зависимости от исхода получаем ответ
    if (config.spacesEnabled && !engineResponce.isEmpty()) {
        bool isHex = true;
        for (const QChar& ch : engineResponce) {
            if (!ch.isDigit() && (ch < 'A' || ch > 'F') && ch != ' ') {
                isHex = false;
                break;
            }
        }

        if (isHex) {
            QString cleanHex = engineResponce;
            cleanHex.replace(" ", "");

            QString spacedResponse = "";
            for (int i = 0; i < cleanHex.length(); i += 2) {
                spacedResponse += cleanHex.mid(i, 2);
                if (i + 2 < cleanHex.length()) {
                    spacedResponse += " ";
                }
            }

            result += spacedResponse + lineEnd;
        } else {
            result += engineResponce + lineEnd;
        }

    } else {
        QString withoutSpaces = engineResponce;
        withoutSpaces.replace(" ", "");
        result += withoutSpaces + lineEnd;
    }

    if (config.appendPrompt) {
        if (!result.endsWith("\r\n")) {
            if (result.endsWith("\r")) {
                result += "\n";
            } else {
                result += "\r\n";
            }
        }
        result += ">";
    }

    return result.toUtf8();
}
