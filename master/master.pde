/*
* Master firmware
* 
* For IED group project
*/

int FSOPin = 13;

void setup(){
  Serial.begin(9600);
  pinMode(FSOPin, OUTPUT);
}

void loop(){
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
      delayMicroseconds(32);
    }
    else{
      delayMicroseconds(16);
    }
    digitalWrite(FSOPin, HIGH);
    delayMicroseconds(16);
  }
}
