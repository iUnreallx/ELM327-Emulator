#include "AtCommandHandler.h"

QString AtCommandHandler::handle(const QString& request, ElmConfig& config) {

    /// полный сброс настреок адаптера
    /// к заводским
    if (request == "ATZ") {
        config.echoEnabled = false;
        config.spacesEnabled = true;
        config.linefeedsEnabled = false;
        config.appendPrompt = true;
        config.headersEnabled = false;

        return "ELM327 v1.5";
    }

    // эхо
    if (request == "ATE0") {
        config.echoEnabled = false;
        return "OK";
    }
    if (request == "ATE1") {
        config.echoEnabled = true;
        return "OK";
    }

    // пробелы
    if (request == "ATS0") {
        config.spacesEnabled = false;
        return "OK";
    }
    if (request == "ATS1") {
        config.spacesEnabled = true;
        return "OK";
    }

    // перенос строки
    if (request == "ATL0") {
        config.linefeedsEnabled = false;
        return "OK";
    }
    if (request == "ATL1") {
        config.linefeedsEnabled = true;
        return "OK";
    }

    // загoловки
    if (request == "ATH0") {
        config.headersEnabled = false;
        return "OK";
    }
    if (request == "ATH1") {
        config.headersEnabled = true;
        return "OK";
    }

    /// возврат напряжения бортовой системы.
    if (request == "ATRV") {
        return QString::number(config.voltage, 'f', 1) + "V";
    }

    /// выбор версии протокола ( просто заглушка )
    if (request.startsWith("ATSP")) {
        if (request.length() > 4) {
            int answer = request.mid(4).toInt();
            config.currentProtocol = request.mid(4).toInt();
        }
        return "OK";
    }

    /// на будущее аппаратные настройки ( тайминги,
    /// пробуждение эбу и тд )
    if (request.startsWith("ATST") || request.startsWith("ATWM") ||
        request.startsWith("ATCRA") || request.startsWith("ATSH")) {
        return "OK";
    }

    /// если чёт неизвестное
    return "?";
}
