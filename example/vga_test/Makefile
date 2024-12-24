CROSS_COMPILE=riscv64-unknown-elf-
CC=$(CROSS_COMPILE)gcc
CFLAGS=-c -nostdlib -march=rv32i -mabi=ilp32
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJCOPYFLAGS=-O binary -j .text
LD=$(CROSS_COMPILE)ld
LDFLAGS=-melf32lriscv
OBJDUMP=$(CROSS_COMPILE)objdump
OBJDUMPFLAGS=-b binary -D -mriscv

all: main.o init.o
	$(LD) $(LDFLAGS) -o final.o init.o main.o
	$(OBJCOPY) $(OBJCOPYFLAGS) final.o final.bin

main.o: main.c
	$(CC) $(CFLAGS) main.c -o main.o

vga.o: lib/vga.c
	$(CC) $(CFLAGS) lib/vga.c -o vga.o

init.o: init.s
	$(CC) $(CFLAGS) init.s -o init.o

objdump: all
	$(OBJDUMP) $(OBJDUMPFLAGS) final.bin | awk '{print $$2}' > final.hex

clean:
	rm -f *.o
	rm -f *.bin