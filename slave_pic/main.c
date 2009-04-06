#include <p18f1320.h>
#include "picduino.h"

/*
* Slave firmware for Free Space Hydroponics
* 
* Receives commands from master device over FSO link
* and adjusts internal settings such as servo values.
*/

#pragma config WDT = OFF
#pragma config OSC = INTIO1
#pragma config DEBUG = OFF, LVP = OFF

//Pin Assignments
int FSOPin = 1; // Chip pin 2
int RedLED = 2; // Chip pin 6
int BlueLED = 3; // Chip pin 7
int CircMotor = 4; // Chip pin 3

//Variables
int BluePWM = 0;
int RedPWM = 0;
byte receive_data[] = {0,0,0};

void receiveFSO(void);
void DisplayLEDs(byte device, byte setting);
void SetCirculator(byte device, byte setting);

void error(byte freq){
  while(1){
    digitalWrite(0, HIGH);
    delay(500/freq);
    digitalWrite(0, LOW);
    delay(500/freq);
  }
}

void morse_byte(byte data){
  char i;
  digitalWrite(7, LOW);
  delay(500);
  for(i = 7; i >= 0; i--){
    digitalWrite(7, HIGH);
    if(data & 0x01<<i)
      delay(1000);
    else
      delay(200);
    digitalWrite(7, LOW);
    delay(500);
  }
}

void setup(void){
  ADCON1 = 0xFF; // no analog inputs
  pinMode(0, OUTPUT);
  pinMode(7, OUTPUT);
  digitalWrite(0, HIGH); // I'm alive
  digitalWrite(7, LOW);
  digitalWrite(FSOPin, 1);
  pinMode(FSOPin, INPUT);
  pinMode(RedLED, OUTPUT);
  pinMode(BlueLED, OUTPUT);
  pinMode(CircMotor, OUTPUT);
}

void loop(void){
  int count;
  if(digitalRead(FSOPin) == HIGH){
    for(count = 0; count < 80; count++){
      delay(10);
      if(digitalRead(FSOPin) == LOW)
        return;
    }
    receiveFSO();
  }
}

void DisplayLEDs(byte device, byte setting){
  if (device == 0x03 && setting != RedPWM){
    RedPWM = setting;
    analogWrite(RedLED, RedPWM);
  }
  else if (device == 0x04 && setting != BluePWM){
    BluePWM = setting;
    analogWrite(BlueLED, BluePWM);
  }  
}

void SetCirculator(byte device, byte setting){
  if (device == 0x01 && setting == 0){
    digitalWrite(CircMotor, LOW);
  }
  else{
    digitalWrite(CircMotor, HIGH);
  }
}
    
void receiveFSO(){
  int duration = 0;
  byte byteIndex = 0;
  byte bitIndex = 0;
  byte readBit = 0;
  long count = 0;
  long i;

  while(digitalRead(FSOPin) == HIGH)
    ; // wait for wake-up phase to complete
  while(1){
    delay(5); // between 2 and 8 milliseconds low time

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

    while(digitalRead(FSOPin) == LOW)
      ;
    while(digitalRead(FSOPin) == HIGH){
      count++;
    }
    if(count > 3200)
      break;
  }

  digitalWrite(0, LOW);
  morse_byte(receive_data[1]);
  digitalWrite(0, HIGH);

  DisplayLEDs(receive_data[1], receive_data[2]);
  SetCirculator(receive_data[1], receive_data[2]);
}

void main(){
  OSCCON = 0x73; // spin up to 8MHz
  setup();
  while(1)
    loop();
}
