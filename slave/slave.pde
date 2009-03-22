/*
* Slave firmware
* 
* For IED group project
*/

int FSOPin = 13;

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
    long start = micros();
    while(digitalRead(FSOPin) == LOW)
      ;
    duration = micros()-start;
    if(duration > 24 && duration < 48)
      readBit = 1; // read a 1
    else if(duration < 24)
      readBit = 0; // read a 0
    else
      break; // error
    
    // interpret bit
    data[byteIndex] |= readBit << bitIndex;
    if(bitIndex >= 8)
      byteIndex++;
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
