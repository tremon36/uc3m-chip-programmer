#include "serial_consumer.h"

void SerialConsumer::receiveUntilEvent(char* buffer, char event) {
  int index = 0;
  bool event_happened = false;
  char in_byte;

  while (!event_happened) {
   if(Serial.available()) {
    in_byte = Serial.read();
    if (in_byte != event) {
      buffer[index++] = in_byte;
    } else {
      buffer[index] = '\0';
      event_happened = true;
    }
   }
  }
}

void SerialConsumer::receiveBytes(char* buffer, int amount) {
  int index = 0;
  char in_byte;
  while (index < amount) {
    if(Serial.available()) {
      in_byte = Serial.read();
      buffer[index++] = in_byte;
    }
  }
}
