/*
* Slave firmware for Free Space Hydroponics
* 
* Receives commands from master device over FSO link
* and adjusts internal settings such as servo values.
*/
#include <Servo.h>

//Pin Assignments
int FSOPin = 12;
int RedLED = 2;
int BlueLED = 3;
int CircMotor = 4;

//Variables
int BluePWM = 0;
int RedPWM = 0;


Servo Feeder;
int FeederPos = 0;

void setup(){
  Serial.begin(9600);
  pinMode(FSOPin, INPUT);
  pinMode(RedLED, OUTPUT);
  pinMode(BlueLED, OUTPUT);
  pinMode(CircMotor, OUTPUT);
  Feeder.attach(3);
}

void loop(){
  if(digitalRead(FSOPin) == HIGH){
    receiveFSO();
  }
  DisplayLEDs();
  SetServo();
  SetCirculator();
}

void DisplayLEDs(){
  if (data[2] == 0x03 && data[3] != RedPWM){
    RedPWM = data[3];
    analogWrite(RedLED, RedPWM);
  }
  else if (data[2] == 0x04 && data[3} != BluePWM){
    BluePWM = data[3];
    analogWrite(BlueLED, BluePWM);
  }  
}

void SetServo(){
  if (data[2] == 0x02 && data[3] != FeederPos){
    FeederPos = data[3];
    Feeder.write(FeederPos);
  }
}

void SetCirculator(){
  if (data[2] == 0x01 && data[3] == 0){
    digitalWrite(CircMotor, LOW);
  }
  else{
    digitalWrite(CircMotor, HIGH);
  }
}
    
void receiveFSO(){
  int duration = 0;
  int data = {0,0,0};
  int byteIndex = 0;
  int bitIndex = 0;
  int readBit = 0;
  int done = 0;
  
  while(digitalRead(FSOPin) == HIGH)
    ; // wait for wake-up phase to complete
  while(done == 0){
    delayMicrosecionds(24); // between 16 and 32 microseconds
    if(digitalRead(FSOPin) == HIGH){
      readBit = 1; // read a 1
    }
    else{
      readBit = 0; // read a 0
    }

    // interpret bit
    data[byteIndex] |= readBit << bitIndex;
    bitIndex = bitIndex + 1;

    if(bitIndex > 7){
      byteIndex++;
      bitIndex = 0;
    }
    
    if(byteIndex >= 3)
      break; // error
    
    start = micros();
    while(digitalRead(FSOPin) == HIGH){
      if(micros() - start > 800){
        done = 1;
        break;
      }
    }
  }
}