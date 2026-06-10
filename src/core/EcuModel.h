#pragma once

#include "src/core/state/EcuState.h"
#include <QObject>

class EcuModel : public QObject {
    Q_OBJECT

    Q_PROPERTY(int speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(int rpm READ rpm WRITE setRpm NOTIFY rpmChanged)

public:
    explicit EcuModel(EcuState* ecuState, QObject *parent = nullptr);

    int speed() const;
    void setSpeed(int newSpeed);

    int rpm() const;
    void setRpm(int newRpm);

signals:
    void speedChanged();
    void rpmChanged();

private:
    EcuState *m_state;
};
