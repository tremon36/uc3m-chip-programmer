# UC3M Chip Programming Software

This repository contains software from the UC3M Microelectronics Research Group for programming custom-designed chips.

## 📁 Folder Structure

- **UI/**  
  PC graphical interface to program the chips.  
  Built with **Dart** and **Flutter**.  
  To edit or build it yourself, use **IntelliJ IDEA** with the Flutter plugin.  
  Pre-built executables are available in the [Releases](../../releases) section.

- **TIVA/**  
  Embedded code for **TIVA C Series** boards.  
  Written as an **Energia IDE** sketch.  
  You can open, edit, and upload the code using Energia.

---

## ✨ Releases

Download ready-to-use builds of the PC application from the [Releases](../../releases) page.

---

## 🛠 Development Setup (Optional)

Only needed if you want to modify or rebuild the UI:

### Requirements
- Flutter SDK
- Dart SDK
- IntelliJ IDEA + Flutter plugin

### Run
```bash
cd UI
flutter run
