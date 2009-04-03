main.hex: main.o
	gplink \
		-c \
		-s /usr/local/share/gputils/lkr/18f1320.lkr \
		-o $@ \
		-m \
		$^ \
		-I /Developer/sdcc/share/sdcc/lib/pic16 \
		libdev18f1320.lib \
		libio18f1320.lib

main.o: main.asm
	gpasm -c $<

main.asm: main.c
	sdcc -S -mpic16 -p18f1320 $<

clean:
	rm main.asm
	rm main.o
	rm main.hex
