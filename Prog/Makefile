# Automatically generates .coe memory files for all c files in the directory.

CC=riscv32-unknown-elf-gcc
CC_FLAGS=-march=rv32i -mabi=ilp32

OBJCOPY=riscv32-unknown-elf-objcopy
OBJCOPY_FLAGS=-O binary -j .text

OBJDUMP=riscv32-unknown-elf-objdump
OBJDUMP_FLAGS=-d

HEXDUMP=hexdump

SRC=$(wildcard *.c)
OBJS=$(wildcard *.o)
COE=$(addsuffix .coe,$(basename $(SRC)))
HEX=$(addsuffix .hex,$(basename $(SRC)))

all: $(COE)

sim: $(HEX)

%.hex: %.bin
	$(HEXDUMP) -v -e '1/4 "%08x\n"' $< > $@

%.o: %.c
	$(CC) $(CC_FLAGS) -c $(SRC)

%.bin: %.o
	$(OBJCOPY) $(OBJCOPY_FLAGS) $< $@

%.coe: %.bin
	echo "memory_initialization_radix=16;" > $@
	echo "memory_initialization_vector=" >> $@
	$(HEXDUMP) -v -e '1/4 "%08x\n"' $< >> $@
	echo ";" >> $@

clean:
	rm -f $(COE) $(OBJS)

dump: $(TARGET).o
	$(OBJDUMP) $(OBJDUMP_FLAGS) $(TARGET).o
