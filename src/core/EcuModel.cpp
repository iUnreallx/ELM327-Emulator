#include "EcuModel.h"

EcuModel::EcuModel(EcuState *state, QObject *parent)
    : QObject(parent), m_state(state) {}


int EcuModel::speed() const {
    return m_state ? m_state->speed : 0;
}

void EcuModel::setSpeed(int newSpeed) {
    if (m_state && m_state->speed != newSpeed) {
        m_state->speed = newSpeed;
        emit speedChanged();
    }
}

int EcuModel::rpm() const {
    return m_state ? m_state->rpm : 0;
}

void EcuModel::setRpm(int newRpm) {
    if (m_state && m_state->rpm != newRpm) {
        m_state->rpm = newRpm;
        emit rpmChanged();
    }
}
