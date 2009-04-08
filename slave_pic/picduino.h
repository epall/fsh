typedef unsigned char byte;

#define OUTPUT 1
#define INPUT 0

#define HIGH 1
#define LOW 0

void pinMode(byte pin, byte direction){
	if(direction == OUTPUT)
		TRISA &= ~(0x01 << pin);
	else
		TRISA |= (0x01 << pin);
}

char digitalRead(byte pin){
	if(PORTA & (0x01 << pin))
		return HIGH;
	return LOW;
}

void digitalWrite(byte pin, byte value){
	if(value == HIGH)
		LATA |= 0x01 << pin;
	else
		LATA &= ~(0x01 << pin);
}

void analogWrite(byte pin, byte value){
    if(value > 128)
        digitalWrite(pin, HIGH);
    else
        digitalWrite(pin, LOW);
	// TODO
}

// Delay for specified number of milliseconds
void delay(long ms)
{
    long i;

    while (ms--)
        for (i=0; i < 68; i++)
            ;
}
