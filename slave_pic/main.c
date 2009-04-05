#include <pic16/pic18fregs.h>
#include "picduino.h"

/*
* Slave firmware for Free Space Hydroponics
* 
* Receives commands from master device over FSO link
* and adjusts internal settings such as servo values.
*/

//Pin Assignments
int FSOPin = 12;
int RedLED = 2;
int BlueLED = 3;
int CircMotor = 4;

//Variables
int BluePWM = 0;
int RedPWM = 0;

void receiveFSO(void);
void DisplayLEDs(BYTE device, BYTE setting);
void SetCirculator(BYTE device, BYTE setting);

void setup(){
  pinMode(FSOPin, INPUT);
  pinMode(RedLED, OUTPUT);
  pinMode(BlueLED, OUTPUT);
  pinMode(CircMotor, OUTPUT);
}

void loop(){
  if(digitalRead(FSOPin) == HIGH){
    receiveFSO();
  }
}

void DisplayLEDs(BYTE device, BYTE setting){
  if (device == 0x03 && setting != RedPWM){
    RedPWM = setting;
    analogWrite(RedLED, RedPWM);
  }
  else if (device == 0x04 && setting != BluePWM){
    BluePWM = setting;
    analogWrite(BlueLED, BluePWM);
  }  
}

void SetCirculator(BYTE device, BYTE setting){
  if (device == 0x01 && setting == 0){
    digitalWrite(CircMotor, LOW);
  }
  else{
    digitalWrite(CircMotor, HIGH);
  }
}
    
void receiveFSO(){
  int duration = 0;
  int byteIndex = 0;
  int bitIndex = 0;
  int readBit = 0;
  BYTE receive_data[] = {0,0,0};
  long count = 0;
  
  while(digitalRead(FSOPin) == HIGH)
    ; // wait for wake-up phase to complete
  while(1){
    delayMicroseconds(24); // between 16 and 32 microseconds
    if(digitalRead(FSOPin) == HIGH){
      readBit = 1; // read a 1
    }
    else{
      readBit = 0; // read a 0
    }

    // interpret bit
    receive_data[byteIndex] |= readBit << bitIndex;
    bitIndex = bitIndex + 1;

    if(bitIndex > 7){
      byteIndex++;
      bitIndex = 0;
    }
    
    if(byteIndex >= 3)
      break; // error
    
    while(digitalRead(FSOPin) == HIGH){
      count++;
      delayMicroseconds(24);
    }
    if(count > 10)
      break;
  }

  DisplayLEDs(receive_data[1], receive_data[2]);
  SetCirculator(receive_data[1], receive_data[2]);
}

void main(){
  setup();
  while(1)
    loop();
}
