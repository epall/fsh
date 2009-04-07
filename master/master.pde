/*
* Master firmware for Free Space Hydroponics
*
* Receives information to transmit from serial port
* and transmits it over FSO link connected to FSOPin
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

/* Write 1 byte to the FSO link.
*  3+7 = 10 milliseconds per bit, giving
*  a bitrate of 100 bits per second
*/
void writeFSO(int value){
  for(int shift = 0; shift < 8; shift++){
    int transmitBit = (value >> shift) & 0x01; // select each bit sequentially
    digitalWrite(FSOPin, LOW);
    if(transmitBit == 1){
      delay(2); // low time
      digitalWrite(FSOPin, HIGH);
      delay(8); // high time
    }
    else{
      delay(8); // low time
      digitalWrite(FSOPin, HIGH);
      delay(2); // high time
    }
  }
}
