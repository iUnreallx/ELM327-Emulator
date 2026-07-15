#include "EcuModel.h"

// #include <QtGlobal>

EcuModel::EcuModel(
    EcuState* state,
    ElmConfig* config,
    QObject* parent )
    : QObject(parent),
    m_state(state),
    m_config(config)
{
}

int EcuModel::speed() const
{
    return m_state ? m_state->speed : 0;
}

void EcuModel::setSpeed(int newSpeed)
{
    if (!m_state || m_state->speed == newSpeed)
        return;

    m_state->speed = newSpeed;
    emit speedChanged();
}

int EcuModel::rpm() const
{
    return m_state ? m_state->rpm : 0;
}

void EcuModel::setRpm(int newRpm)
{
    if (!m_state || m_state->rpm == newRpm)
        return;

    m_state->rpm = newRpm;
    emit rpmChanged();
}

int EcuModel::coolantTemp() const
{
    return m_state ? m_state->coolantTemp : 0;
}

void EcuModel::setCoolantTemp(int newCoolantTemp)
{
    if (!m_state || m_state->coolantTemp == newCoolantTemp)
        return;

    m_state->coolantTemp = newCoolantTemp;
    emit coolantTempChanged();
}

double EcuModel::voltage() const
{
    return m_config ? m_config->voltage : 0.0;
}

void EcuModel::setVoltage(double newVoltage)
{
    if (!m_config)
        return;

    if (qFuzzyCompare(m_config->voltage + 1.0, newVoltage + 1.0))
        return;

    m_config->voltage = newVoltage;
    emit voltageChanged();
}

int EcuModel::engineLoad() const
{
    return m_state ? m_state->engineLoad : 0;
}

void EcuModel::setEngineLoad(int newEngineLoad)
{
    if (!m_state)
        return;

    newEngineLoad = qBound(0, newEngineLoad, 100);

    if (m_state->engineLoad == newEngineLoad)
        return;

    m_state->engineLoad = newEngineLoad;
    emit engineLoadChanged();
}

int EcuModel::throttlePosition() const
{
    return m_state ? m_state->throttlePosition : 0;
}

void EcuModel::setThrottlePosition(int newThrottlePosition)
{
    if (!m_state)
        return;

    newThrottlePosition = qBound(0, newThrottlePosition, 100);

    if (m_state->throttlePosition == newThrottlePosition)
        return;

    m_state->throttlePosition = newThrottlePosition;
    emit throttlePositionChanged();
}
