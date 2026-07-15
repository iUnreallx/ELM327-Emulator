#pragma once

#include "src/core/state/EcuState.h"
#include "src/core/state/ElmConfig.h"
#include <QObject>

class EcuModel : public QObject {
    Q_OBJECT

    Q_PROPERTY(
        int speed
        READ speed
        WRITE setSpeed
        NOTIFY speedChanged
    )

    Q_PROPERTY(
        int rpm
        READ rpm
        WRITE setRpm
        NOTIFY rpmChanged
    )

    Q_PROPERTY(
        int coolantTemp
        READ coolantTemp
        WRITE setCoolantTemp
        NOTIFY coolantTempChanged
    )

    Q_PROPERTY(
        double voltage
        READ voltage
        WRITE setVoltage
        NOTIFY voltageChanged
    )

    Q_PROPERTY(
        int engineLoad
        READ engineLoad
        WRITE setEngineLoad
        NOTIFY engineLoadChanged
    )

    Q_PROPERTY(
        int throttlePosition
        READ throttlePosition
        WRITE setThrottlePosition
        NOTIFY throttlePositionChanged
    )

public:
    explicit EcuModel(EcuState* ecuState, ElmConfig* elmConfig, QObject *parent = nullptr);

    int speed() const;
    void setSpeed(int newSpeed);

    int rpm() const;
    void setRpm(int newRpm);

    int coolantTemp() const;
    void setCoolantTemp(int newCoolantTemp);

    double voltage() const;
    void setVoltage(double newVoltage);

    int engineLoad() const;
    void setEngineLoad(int newEngineLoad);

    int throttlePosition() const;
    void setThrottlePosition(int newThrottlePosition);

signals:
    void speedChanged();
    void rpmChanged();
    void coolantTempChanged();
    void voltageChanged();
    void engineLoadChanged();
    void throttlePositionChanged();

private:
    EcuState* m_state = nullptr;
    ElmConfig* m_config = nullptr;
};
