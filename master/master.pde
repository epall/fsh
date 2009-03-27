/*
* Master firmware
* 
* For IED group project
*/

int FSOPin = 12;

void setup(){
  Serial.begin(9600);
  pinMode(FSOPin, OUTPUT);
}

void loop(){
  //loop
  int device,setting,value;
  if(Serial.available() >= 3){
    // we have a full packet from the desktop
    device = Serial.read();
    setting = Serial.read();
    value = Serial.read();
    beginFSO();
    writeFSO(device);
    writeFSO(setting);
    writeFSO(value);
    endFSO();
  }
}

void beginFSO(){
  digitalWrite(FSOPin, HIGH);
  delay(1000);
}

void endFSO(){
  delay(1000);
  digitalWrite(FSOPin, LOW);
}

void writeFSO(int value){
  for(int shift = 0; shift < 8; shift++){
    int transmitBit = (value >> shift) & 0x01;
    digitalWrite(FSOPin, LOW);
    if(transmitBit == 1){
      delayMicroseconds(32); // low time
      digitalWrite(FSOPin, HIGH);
      delayMicroseconds(16); // high time
    }
    else{
      delayMicroseconds(16); // low time
      digitalWrite(FSOPin, HIGH);
      delayMicroseconds(32); // high time
    }
  }
}
