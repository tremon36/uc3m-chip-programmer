#include "actions.h"
#include "serial_consumer.h"

enum class Chip { DOGX, DOG15, NONE };
enum class Command { HIZ, RESET, PROGRAM, NONE };

Chip fetch_chip(const char* chip_name) {
  String cc(chip_name);
  if (cc == "DOGX") return Chip::DOGX;
  if (cc == "DOG15") return Chip::DOG15;
  Serial.println("No chip detected");
  return Chip::NONE;
}

Command fetch_command(const char* command_name) {
  String cc(command_name);
  if (cc == "HIZ") return Command::HIZ;
  if (cc == "RESET") return Command::RESET;
  if (cc == "DATA") return Command::PROGRAM;
  return Command::NONE;
}

SerialConsumer ser;

void setup() {
  iosetup();
}

void loop() {
  
  // Command format is CHIP_NAME:COMMAND_NAME:COMAND_ARGS(OPTIONAL)\n
  
  // First stage: Receive chip
  char chip_name[10];
  ser.receiveUntilEvent(chip_name, ':');
  Chip cp = fetch_chip(chip_name);
  // Second stage: fetch command for each chip. If more chips are added, an
  // OOP approach might be benefitial
  char command_name[20];
  Command c;
  switch (cp) {
    case Chip::DOG15:
      ser.receiveUntilEvent(command_name, ':');
      c = fetch_command(command_name);
      switch (c) {
        case Command::HIZ:
          Serial.println("(DOG15) HI_Z TOGGLED");
          toggle_hiz();
          break;
        case Command::RESET:
          Serial.println("(DOG15) RESET SIGNAL DETECTED");
          runReset();
          break;
        case Command::PROGRAM:
          char program_data[14];
          ser.receiveBytes(program_data, 14);
          Serial.println("(DOG15) PROGRAM RECEIVED");
          programChip((byte*)program_data, 14);
          break;
        default:
          break;
      }
      break;
    case Chip::DOGX:
      ser.receiveUntilEvent(command_name, ':');
      c = fetch_command(command_name);
      switch (c) {
        case Command::HIZ:
          Serial.println("(DOGX) HI_Z TOGGLED");
          toggle_hiz();
          break;
        case Command::RESET:
          Serial.println("(DOGX) RESET SIGNAL DETECTED");
          runReset();
          break;
        case Command::PROGRAM:
          char program_data[9]; 
          ser.receiveBytes(program_data, 9);
          Serial.println("(DOGX) PROGRAM RECEIVED");
          programChip((byte*) program_data, 9);
          break;
        default:
          break;
      }
      break;
  }
  // In case of error, just fetch the complete line, get ready for the next
  // one
  char trash[100];
  ser.receiveUntilEvent(trash, '\n');
}
