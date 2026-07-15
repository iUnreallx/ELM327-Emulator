## Roadmap

### Core Architecture

- [x] ~~Separate ELM327 protocol logic from the transport layer~~
- [x] ~~Add a transport-independent emulator core~~
- [x] ~~Implement buffered input and command boundary handling~~
- [x] ~~Add persistent ELM327 session state~~
- [x] ~~Add centralized response formatting~~
- [x] ~~Add structured OBD2 PID handling~~
- [x] ~~Add supported PID discovery through Mode `01 PID 00`~~

### Vehicle Data

- [x] ~~Add engine RPM — `010C`~~
- [x] ~~Add vehicle speed — `010D`~~
- [x] ~~Add coolant temperature — `0105`~~
- [x] ~~Add battery voltage — `ATRV`~~
- [x] ~~Add calculated engine load — `0104`~~
- [x] ~~Add throttle position — `0111`~~
- [ ] Add more standard OBD2 parameters and control cards
- [ ] Add supported PID masks for ranges `0120`, `0140`, and later ranges
- [ ] Add configurable vehicle and ECU profiles

### Value Simulation

- [ ] Add manual, random, and automatic value modes
- [ ] Add configurable minimum and maximum values
- [ ] Add smooth value transitions instead of instant random jumps
- [ ] Add linked parameter simulation for RPM, throttle, speed, and engine load
- [ ] Add reusable driving scenarios such as idle, acceleration, cruising, and braking

### Response Simulation

- [x] ~~Add configurable AT command delay~~
- [x] ~~Add configurable OBD2 response delay~~
- [x] ~~Add random response jitter~~
- [ ] Add configurable probability of delayed responses
- [ ] Add timeout and no-response simulation
- [ ] Add `NO DATA`, `UNABLE TO CONNECT`, and bus error simulation
- [ ] Add malformed and incomplete response simulation
- [ ] Add connection interruption scenarios

### Multi-Frame Responses

- [ ] Refactor command handlers to return one or multiple response frames
- [ ] Add multiline response formatting
- [ ] Add ISO-TP-style CAN frame segmentation
- [ ] Add Mode `09 PID 02` VIN responses
- [ ] Add configurable VIN and vehicle information
- [ ] Support responses from multiple ECUs

### Diagnostic Trouble Codes

- [ ] Add configurable stored DTCs
- [ ] Add Mode `03` stored DTC responses
- [ ] Add Mode `04` DTC clearing
- [ ] Add Mode `07` pending DTC responses
- [ ] Add MIL / Check Engine status simulation
- [ ] Build a DTC management page

### Transport Layer

- [x] ~~Add serial and virtual COM-port communication~~
- [x] ~~Introduce a reusable transport interface~~
- [ ] Add TCP server transport for Wi-Fi connections
- [ ] Add native Bluetooth transport
- [ ] Allow transport-specific configuration without changing the emulator core

### Interface

- [x] ~~Add vehicle parameter cards~~
- [x] ~~Add connection management page~~
- [x] ~~Add RX/TX logs with pause, clear, and export controls~~
- [x] ~~Add response delay configuration page~~
- [ ] Add simulation and error configuration page
- [ ] Add DTC management page
- [ ] Add vehicle profile management
- [ ] Add application settings
- [ ] Add language selection and localization
- [ ] Save UI and emulator settings between launches

### Quality and Testing

- [ ] Add automated tests for AT commands
- [ ] Add automated tests for PID encoding
- [ ] Add tests for supported PID masks
- [ ] Add tests for response formatting
- [ ] Add tests for buffered and multiline commands
- [ ] Add tests for VIN and multi-frame responses
- [ ] Add end-to-end compatibility tests with ReDrive