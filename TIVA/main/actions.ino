#ifndef _ACTIONS
#define _ACTIONS

#define data_out PB_1 // data out, SDI
#define clk_out PB_4 // SCLK
#define chipSelectPin PB_6 // CS

#include <arduino.h>

void runReset(void) {
  digitalWrite(data_out,LOW);
  digitalWrite(chipSelectPin, HIGH);
  delayMicroseconds(500);
  digitalWrite(clk_out,HIGH);
  delayMicroseconds(2500);
  digitalWrite(clk_out,LOW);
  delayMicroseconds(500);
  digitalWrite(chipSelectPin, HIGH);
}

void toggle_hiz(void) {
  static int hiz_state = 0;
  if(!hiz_state) {
  digitalWrite(clk_out,LOW);
  digitalWrite(chipSelectPin, HIGH);
  delayMicroseconds(500);
  digitalWrite(data_out,HIGH);
  Serial.println("HIZ SHORTED");
  } else {
  digitalWrite(data_out,LOW);
  delayMicroseconds(500);
  digitalWrite(chipSelectPin, HIGH);
  Serial.println("HIZ NORMAL OPERATION");
  }
  hiz_state = !hiz_state;
}

void programChip(byte* data, int byteAmount) {
  digitalWrite(chipSelectPin, LOW);
  for (int i = 0; i < byteAmount; i++) {
    for(int j = 7; j >= 0; j--) {
      byte result = (data[i] & (1 << j)) >> j;
      if(result == 1) digitalWrite(data_out,HIGH);
      else digitalWrite(data_out,LOW);
      delayMicroseconds(50);
      digitalWrite(clk_out, HIGH);
      delayMicroseconds(50);
      digitalWrite(clk_out, LOW);
    }
  }
  delayMicroseconds(50);
  digitalWrite(chipSelectPin, HIGH);
  delayMicroseconds(50);
  digitalWrite(data_out,LOW);
}

inline void iosetup(void) {
  Serial.begin(115200);
  while(!Serial);
  pinMode(chipSelectPin, OUTPUT);
  pinMode(data_out, OUTPUT);
  pinMode(clk_out, OUTPUT);
  digitalWrite(chipSelectPin, HIGH);
  digitalWrite(clk_out,LOW);
  digitalWrite(data_out,LOW);
  Serial.println("(TIVA) TIVA CONNECTED");
}

#endif
