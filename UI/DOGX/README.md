## 🧠 Overview of `lib/` (Flutter Programmer App)

This module implements the core logic of a Flutter-based serial programmer interface for managing **microcontroller register data** via a UI and serial communication.

---

### 🔧 Key Concepts & Architecture

- **Registers & Chips:**
  - `Register`: Represents a configurable field with metadata like name, bit-width, signed/unsigned, and value.
  - `Chip`: A named collection of registers, treated as a programmable unit.
  - `RegisterList`: Static manager class that stores all chips and provides methods to encode register values for transmission.

- **Serialization & Storage:**
  - `json_file_handler.dart`: Handles reading/writing chip-register structures to a JSON file for persistence.
  - Chips and registers can be saved and restored between sessions.

- **UI Components:**
  - `ui_page.dart`: The main interactive page that loads chip data, shows registers, and interacts with the serial port.
  - `register_view.dart`: Widget for editing a single register's value, with constraints like bit width and signedness.

- **State Management:**
  - Uses `Provider` (`reg_provider.dart`) for UI state updates — primarily to reflect register changes.
  - `RegProvider` is a singleton with a simple `notifyListeners()` call.

- **Serial Communication:**
  - `serial_wr.dart`: Uses `flutter_libserialport` to send and receive byte-encoded register data over a serial interface.
  - Exposes `begin()` to open a port and `listen()` to react to incoming data.

---

### 📁 File Summary

| File | Description |
|------|-------------|
| `main.dart` | Initializes chips from JSON and launches the UI with Provider. |
| `chip.dart` | Model for a Chip containing a list of Registers. |
| `register.dart` | Data model for a Register, with helper methods for bit conversion. |
| `register_list.dart` | Static logic for register encoding and chip register access. |
| `register_view.dart` | UI component to view/edit a single register. |
| `ui_page.dart` | Main UI page with chip management and serial interaction. |
| `reg_provider.dart` | Simple provider for triggering UI refreshes. |
| `serial_wr.dart` | Serial port wrapper using `flutter_libserialport`. |
| `json_file_handler.dart` | JSON serialization/deserialization of chip data. |
