CROSS_COMPILE=riscv64-unknown-elf-
CC=$(CROSS_COMPILE)gcc
CFLAGS=-nostdlib -march=rv32i -mabi=ilp32

OBJCOPY=$(CROSS_COMPILE)objcopy
OBJCOPYFLAGS=-O binary -j .text

LD=$(CROSS_COMPILE)ld
LDFLAGS=-melf32lriscv

OBJDUMP=$(CROSS_COMPILE)objdump
OBJDUMPFLAGS=-b binary -D -mriscv

all: init.o main.o
	$(LD) $(LDFLAGS) -o final.o init.o main.o
	$(OBJCOPY) $(OBJCOPYFLAGS) final.o final.bin

main.o: main.c
	$(CC) $(CFLAGS) main.c int.s lib/std.c lib/vga.c lib/key.c -o main.o

init.o: init.s
	$(CC) $(CFLAGS) -c init.s -o init.o

objdump: all
	$(OBJDUMP) $(OBJDUMPFLAGS) final.bin > final.hex

clean:
	rm -f *.o
	rm -f *.bin

# riscv64-unknown-elf-gcc -nostdlib -march=rv32i -mabi=ilp32 -lgcc main.c lib/vga.c lib/key.c -o main