# FPGA Secure Access Control System (Verilog)

stateDiagram-v2
    [*] --> IDLE
    IDLE --> S1 : Input = 1
    IDLE --> ERROR : Input != 1
    
    S1 --> S2 : Input = 2
    S1 --> ERROR : Input != 2
    
    S2 --> S3 : Input = 3
    S2 --> ERROR : Input != 3
    
    S3 --> OPEN : Input = 4
    S3 --> ERROR : Input != 4
    
    ERROR --> IDLE : Reset
    ERROR --> ALARM : Errors >= 3
    
    OPEN --> IDLE : Reset
    ALARM --> [*] : Hard Lock

## Project Overview
This project implements a **Hardware-Based Security System** using a Finite State Machine (FSM) in Verilog. Unlike software passwords which can be bypassed via memory buffer overflows, this logic is synthesized directly into hardware gates, providing a "Hardware Root of Trust."

**Key Features:**
* **Sequential Logic:** Requires a precise 4-digit input sequence (1-2-3-4).
* **Brute Force Protection:** Automatically locks the system into an `ALARM` state after 3 failed attempts.
* **Tamper Resistant:** The state machine cannot be reset without a hardware `RST` signal.

## Technical Architecture
The system uses a Moore Machine FSM with the following states:
1.  **IDLE:** Waiting for input.
2.  **S1-S3:** Intermediate states tracking correct digits.
3.  **OPEN:** Access granted (High Signal).
4.  **ERROR/ALARM:** Logic trap for incorrect entries.

### State Transition Diagram
*(See `secure_lock.v` for full transition logic)*

## Simulation Results & Verification

Challenges
Signal Debouncing: In this simulation, button presses are ideal square waves. If deploying to a physical FPGA (like a Basys 3), I would need to add a Debounce Module to filter out the mechanical noise from physical switches, otherwise, one press would register as multiple inputs.

**Tools Used:** Icarus Verilog 12.0, GTKWave/EPWave

### 1. Successful Access
The waveform below demonstrates a valid entry sequence (`1 -> 2 -> 3 -> 4`). The `unlock` signal (bottom line) transitions to HIGH only after the 4th correct digit is latched.

![Waveform Success](waveform_evidence.png)

### 2. Security Lockout (Brute Force Test)
The testbench simulates an attacker entering random digits (`9-8-7`).
* **Attempt 1 & 2:** System remains locked.
* **Attempt 3:** The `alarm` signal triggers HIGH.
* **Result:** The system enters a hard lockout state, ignoring all further input.

**Console Output:**
```text
Test 1: Entering Correct Password...
SUCCESS: Door Unlocked!
Test 2: Simulating Brute Force Attack...
SUCCESS: Alarm Triggered!