#include "DelayManager.h"

DelayManager::DelayManager(QObject *parent)
    : QObject(parent),
    m_atDelay(500),
    m_obdDelay(50),
    m_jitter(0)
{
}

int DelayManager::atDelay() const {
    return m_atDelay;
}

void DelayManager::setAtDelay(int delay) {
    if (m_atDelay != delay) {
        m_atDelay = delay;
        emit atDelayChanged();
    }
}


int DelayManager::obdDelay() const {
    return m_obdDelay;
}

void DelayManager::setObdDelay(int delay) {
    if (m_obdDelay != delay) {
        m_obdDelay = delay;
        emit obdDelayChanged();
    }
}

int DelayManager::jitter() const {
    return m_jitter;
}

void DelayManager::setJitter(int j) {
    if (m_jitter != j) {
        m_jitter = j;
        emit jitterChanged();
    }
}
