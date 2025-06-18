#ifndef _SERIAL_CONSUMER_H
#define _SERIAL_CONSUMER_H

class SerialConsumer {
 public:
  // Fills the buffer until the 'event' character is found, replaces it with '\0'
  void receiveUntilEvent(char* buffer, char event);

  // Reads a fixed number of bytes into the buffer (no null terminator)
  void receiveBytes(char* buffer, int amount);
};

#endif // _SERIAL_CONSUMER_H
