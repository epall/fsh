typedef unsigned char BYTE;

#define OUTPUT 1
#define INPUT 0

#define HIGH 1
#define LOW 0

void pinMode(BYTE pin, BYTE direction){
	if(direction == OUTPUT)
		TRISA &= ~(0x01 << pin);
	else
		TRISA |= (0x01 << pin);
}

char digitalRead(BYTE pin){
	if(PORTA & (0x01 << pin))
		return HIGH;
	return LOW;
}

void digitalWrite(BYTE pin, BYTE value){
	if(value == HIGH)
		LATA |= 0x01 << pin;
	else
		LATA &= ~(0x01 << pin);
}

void analogWrite(BYTE pin, BYTE value){
	// TODO
}

// locked to 24 microseconds
void delayMicroseconds(char d) {
	_asm
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	_endasm;
}

// Delay for specified number of milliseconds
void delay(long ms)
{
    long i;

    while (ms--)
        for (i=0; i < 330; i++)
            ;
}
