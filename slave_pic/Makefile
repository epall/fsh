test.hex: test.o
	gplink \
		-c \
		-s /usr/local/share/gputils/lkr/18f1320.lkr \
		-o $@ \
		-m \
		$^ \
		-I /Developer/sdcc/share/sdcc/lib/pic16 \
		libdev18f1320.lib \
		libio18f1320.lib

slave.hex: main.o
	gplink \
		-c \
		-s /usr/local/share/gputils/lkr/18f1320.lkr \
		-o $@ \
		-m \
		$^ \
		-I /Developer/sdcc/share/sdcc/lib/pic16 \
		libdev18f1320.lib \
		libio18f1320.lib

%.o: %.asm
	gpasm -c $<

test.asm: test.c picduino.h
	sdcc -S -mpic16 -p18f1320 $<

main.asm: main.c picduino.h
	sdcc -S -mpic16 -p18f1320 $<

clean:
	rm *.o
	rm *.asm
	rm *.hex

