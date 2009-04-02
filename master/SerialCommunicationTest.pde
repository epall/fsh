 int val;
 int ledPin = 13;
 int device = 0;
 int setting = 0;
 int value = 0;
 void setup() {
   Serial.begin(9600);

    pinMode(ledPin, OUTPUT);
    digitalWrite(ledPin, HIGH);
    delay(250);
    digitalWrite(ledPin, LOW);
 }  
 
 void loop() {
   if(Serial.available() >= 3){
    // we have a full packet from the desktop
    device = Serial.read();
    setting = Serial.read();
    value = Serial.read(); 
  
    for(int i = 0; i < device; i++) {
       digitalWrite(ledPin, HIGH);
       delay(250);
       digitalWrite(ledPin, LOW);
       delay(250);
     }
     delay(1000)
    for(int i = 0; i < setting; i++) {
       digitalWrite(ledPin, HIGH);
       delay(250);
       digitalWrite(ledPin, LOW);
       delay(250);
     }
     delay(1000)
    for(int i = 0; i < value; i++) {
       digitalWrite(ledPin, HIGH);
       delay(250);
       digitalWrite(ledPin, LOW);
       delay(250);
     } 
   val = 0;
 }
 }
