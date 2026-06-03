#pragma once

#include <QString>

struct ElmConfig {
    /// x - число, либо 1 либо 0.

    /// Базовые настройки отображения
    bool echoEnabled = false;       // AT Ex - AT Ex (Повторять ли команду пользователя)
    bool appendPrompt = true;      // Добавлять ли > в конце
    bool spacesEnabled = true;     // AT Sx - AT Sx (Пробелы в ответах)
    bool linefeedsEnabled = false;  // AT Lx / AT Lx (Добавлять ли \n после каждого \r)

    /// Настройка протоколов и шины
    int currentProtocol = 0;       // AT SP x (0 - автопоиск; выбор протокола)
    bool headersEnabled = false;   // AT Hx / AT Hx (Показывать ли адреса блоков.) / В будущем поддержка мульти эбу

    /// физические показатели
    double voltage = 14.5;  // AT RV
};
