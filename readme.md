<a id="readme"></a>
<div align="center">

![Preview](Qml/assets/preview.png)

![C++](https://img.shields.io/badge/C++-17/20-00599C?style=for-the-badge&logo=cplusplus&logoColor=white)
![Qt](https://img.shields.io/badge/Qt-6-41CD52?style=for-the-badge&logo=qt&logoColor=white)
![QML](https://img.shields.io/badge/QML-UI-41CD52?style=for-the-badge&logo=qt&logoColor=white)
![ELM327](https://img.shields.io/badge/ELM327-Emulator-00B8FF?style=for-the-badge)
![Contributions Welcome](https://img.shields.io/badge/Contributions-Welcome-22C55E?style=for-the-badge)
![Issues](https://img.shields.io/github/issues/iUnreallx/ELM327-Emulator?style=for-the-badge)
![Stars](https://img.shields.io/github/stars/iUnreallx/ELM327-Emulator?style=for-the-badge)

</div>

# ELM327 Emulator

> **ELM327 Emulator** is a lightweight open-source desktop tool for simulating ELM327 / OBD2 adapter responses without real vehicle hardware.

It allows developers to test OBD2 dashboards, diagnostic tools, and serial communication logic in a controlled virtual environment.

## About The Project

**ELM327 Emulator** was created to simplify development and testing of OBD2-based applications.

Instead of connecting to a real car and physical ELM327 adapter every time, the emulator provides predictable diagnostic responses through a serial interface.

The project is useful for:

- testing OBD2 dashboards;
- debugging ELM327 command handling;
- simulating vehicle telemetry;
- developing without real hardware;
- learning how ELM327 / OBD2 communication works.

## Key Features

- **ELM327 Command Simulation**  
  Handles common ELM327 and OBD2 requests.

- **Live Vehicle Data Emulation**  
  Simulates RPM, speed, coolant temperature, and battery voltage.

- **Serial Port Communication**  
  Works through a COM / serial-port based transport layer.

- **Qt/QML Interface**  
  Provides a clean desktop UI for controlling simulated vehicle values.

- **Developer Friendly**  
  Designed for testing, debugging, and future protocol expansion.

## Built With

- **C++**
- **Qt 6**
- **QML**
- **Qt SerialPort**
- **CMake**

## Why ELM327 Emulator?

Testing OBD2 applications usually requires:

1. a car;
2. an ELM327 adapter;
3. a stable connection;
4. repeated manual testing.

This emulator removes that dependency.

It gives developers a simple virtual environment where they can test how their application reacts to diagnostic commands and changing vehicle data.

## Installation and Setup

To build the project, you need:

- Qt 6.5 or newer;
- CMake 3.16 or newer;
- a C++ compiler;
- Qt SerialPort module.

### 1. Clone the repository

```sh
git clone https://github.com/iUnreallx/ELM327-Emulator.git
```

### 2. Open the project

```sh
cd ELM327-Emulator
```

### 3. Build with CMake

```sh
cmake -B build
cmake --build build
```

### 4. Run the application

```sh
./build/appObd2-Emulator
```

## Repository Structure

```sh
ELM327-Emulator/
├── Qml/                              # QML user interface
│   ├── Main.qml                      # Application entry point
│   ├── MainPage.qml                  # Main page
│   ├── Obd2Screen.qml                # OBD2 emulator screen
│   ├── Speedometers/                 # Speed, RPM, temperature, voltage gauges
│   └── assets/                       # Images, icons, fonts
│
├── Src/
│   ├── Header/                       # Header files
│   │   ├── SerialPortScanner.h       # Serial port scanner
│   │   ├── SerialPortConnector.h     # Connection controller
│   │   └── SerialPortWorker.h        # Serial transport worker
│   │
│   └── Source/                       # Source files
│       ├── SerialPortScanner.cpp
│       ├── SerialPortConnector.cpp
│       └── SerialPortWorker.cpp
│
├── CMakeLists.txt                    # Build configuration
├── readme.md                         # Project documentation
└── LICENSE                           # Project license
```

## How It Works

The emulator receives ELM327 / OBD2 commands through a serial connection and returns simulated responses.

Basic flow:

```sh
OBD2 App
   ↓
Serial Port
   ↓
ELM327 Emulator
   ↓
Simulated OBD2 Response
```

Example commands:

```sh
010C    # Engine RPM
010D    # Vehicle speed
0105    # Coolant temperature
ATRV    # Battery voltage
ATZ     # Reset
```

## Roadmap

- Separate ELM327 protocol logic from serial transport;
- Add transport-independent emulator core;
- Improve command parser with buffered input support;
- Add ELM327 session state;
- Add response formatter;
- Add PID handler registry;
- Add golden tests for stable protocol behavior.

## Contributing

Contributions are welcome.

If you want to improve the emulator:

1. Fork the repository.
2. Create a new branch.

```sh
git checkout -b feature/my-feature
```

3. Commit your changes.

```sh
git commit -m "Add my feature"
```

4. Push the branch.

```sh
git push origin feature/my-feature
```

5. Open a Pull Request.

## License

The project is distributed under the MIT license. See the [LICENSE](LICENSE) file for details.

## Contact

GitHub: [@iUnreallx](https://github.com/iUnreallx)

Project Link: [https://github.com/iUnreallx/ELM327-Emulator](https://github.com/iUnreallx/ELM327-Emulator)
<p align="right">(<a href="#readme">back to top</a>)</p>