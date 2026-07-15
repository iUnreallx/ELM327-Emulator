#pragma once
#include <QObject>

class DelayManager : public QObject {
    Q_OBJECT

    Q_PROPERTY(int atDelay READ atDelay WRITE setAtDelay NOTIFY atDelayChanged)
    Q_PROPERTY(int obdDelay READ obdDelay WRITE setObdDelay NOTIFY obdDelayChanged)
    Q_PROPERTY(int jitter READ jitter WRITE setJitter NOTIFY jitterChanged)

public:
    explicit DelayManager(QObject *parent = nullptr);

    int atDelay() const;
    void setAtDelay(int delay);

    int obdDelay() const;
    void setObdDelay(int delay);

    int jitter() const;
    void setJitter(int j);

signals:
    void atDelayChanged();
    void obdDelayChanged();
    void jitterChanged();

private:
    int m_atDelay;
    int m_obdDelay;
    int m_jitter;
};
