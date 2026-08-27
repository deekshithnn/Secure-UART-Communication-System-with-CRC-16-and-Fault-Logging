Verification and Fault Logging

## 📌 Project Overview

This project implements a **secure UART-based communication system** using Verilog HDL.

The system receives UART data, temporarily stores incoming bytes in a FIFO buffer, parses the received packet, calculates a CRC-16 value, compares it with the received CRC, and generates security status signals.

If a CRC mismatch occurs, the system generates an alert and logs the fault information.

---

## 🚀 Features

- UART Receiver
- FIFO Buffer for temporary data storage
- Packet-based communication
- CRC-16 error detection
- Automatic CRC verification
- Security OK indication
- Security Error indication
- Alert generation
- Fault logging
- CRC error counter
- Storage of last received CRC
- Storage of last calculated CRC
- Multiple CRC error detection

---

## 🧩 System Architecture

```text
                UART DATA
                    │
                    ▼
              ┌───────────┐
              │  UART RX  │
              └─────┬─────┘
                    │
                    ▼
              ┌───────────┐
              │   FIFO    │
              └─────┬─────┘
                    │
                    ▼
              ┌───────────────┐
              │ Packet Parser │
              └───────┬───────┘
                      │
          ┌───────────┴───────────┐
          ▼                       ▼
     Sensor Data              Received CRC
          │                       │
          ▼                       │
       CRC-16                     │
          │                       │
          └───────────┬───────────┘
                      ▼
              ┌───────────────┐
              │ Security Check│
              └───────┬───────┘
                      │
             ┌────────┴────────┐
             ▼                 ▼
        SECURITY OK      SECURITY ERROR
                                  │
                                  ▼
                               ALERT
                                  │
                                  ▼
                            FAULT LOGGER
                                  │
                                  ▼
                  Error Count + CRC Information
📦 Packet Format

The UART packet format is:

| HEADER | DATA | CRC_H | CRC_L |

Example:

| 0xAA | 0x41 | CRC High | CRC Low |
0xAA → Packet Header
DATA → Sensor/Data Byte
CRC_H → High byte of CRC-16
CRC_L → Low byte of CRC-16
📁 Project Structure
Secure_UART_Communication_System/
│
├── README.md
│
├── rtl/
│   ├── uart_rx.v
│   ├── fifo.v
│   ├── packet_parser.v
│   ├── crc16.v
│   ├── security_controller.v
│   ├── fault_logger.v
│   └── uart_packet_security_fault_top.v
│
├── tb/
│   ├── uart_rx_tb.v
│   ├── packet_parser_tb.v
│   ├── fault_logger_tb.v
│   └── uart_packet_security_fault_top_tb.v
│
├── simulation/
│   └── screenshots/
│       ├── correct_crc.png
│       ├── wrong_crc.png
│       └── fault_logging.png
│
└── docs/
    └── block_diagram.png
⚙️ RTL Modules
1. UART Receiver

Receives serial UART data and converts it into parallel 8-bit data.

2. FIFO Buffer

Temporarily stores incoming UART bytes and controls data flow using:

Write Enable
Read Enable
Full Flag
Empty Flag
3. Packet Parser

Extracts the following fields from the UART packet:

HEADER → DATA → CRC_H → CRC_L
4. CRC-16 Module

Calculates the CRC value for the received data.

5. Security Controller

Compares:

Calculated CRC
        vs
Received CRC

Outputs:

security_ok
security_error
alert
6. Fault Logger

When a CRC error occurs, the fault logger:

Increments error_count
Stores last_received_crc
Stores last_calculated_crc
Sets fault_flag
🧪 Verification

The complete design was verified using a Verilog testbench.

Test 1: Correct CRC Packet

Expected:

security_ok    = 1
security_error = 0
alert          = 0
error_count    = 0
Test 2: Wrong CRC Packet

Expected:

security_ok    = 0
security_error = 1
alert          = 1
error_count    = 1
Test 3: Multiple Wrong CRC Packets

Expected error count progression:

Error 1 → error_count = 1
Error 2 → error_count = 2
Error 3 → error_count = 3

Final result:

Total CRC Errors = 3
fault_flag       = 1
🛠️ Tools Used
Verilog HDL
Xilinx Vivado
XSIM Simulator
🎯 Learning Outcomes

Through this project, the following concepts were implemented and verified:

UART communication
FIFO design and integration
Finite State Machine based packet parsing
CRC-16 based error detection
RTL module integration
Fault monitoring
Functional simulation and verification
Verilog testbench development
🔮 Future Improvements
Multi-byte payload support
UART transmitter
Configurable CRC polynomial
Timeout detection
FIFO overflow handling
Error recovery mechanism
Interrupt generation
FPGA hardware implementation
AES encryption for secure communication
👨‍💻 Author

Deekshith N N

Electronics and Communication Engineering
Interested in VLSI, RTL Design, Embedded Systems and FPGA Development
