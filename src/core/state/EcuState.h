#pragma once

struct EcuState {
    double voltage = 14.5;

    int rpm = 800;
    int speed = 0;
    int coolantTemp = 90;
};
