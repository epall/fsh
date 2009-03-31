/*
* Slave firmware for Free Space Hydroponics
* 
* Receives commands from master device over FSO link
* and adjusts internal settings such as servo values.
*/

int FSOPin = 12;

void setup(){
  Serial.begin(9600);
  pinMode(FSOPin, INPUT);
}

void loop(){
  if(digitalRead(FSOPin) == HIGH){
    receiveFSO();
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
