source=$(wildcard tmp/*.S)
objects=$(source:.S=.o)
elfs=$(source:.S=.elf)
dumps=$(source:.S=.dump)

CFLAGS=-c -O0 -ffreestanding -nostartfiles -ffunction-sections -march=rv32im -mabi=ilp32
LDFLAGS=-T link.ld -A elf32lriscv

default: $(elfs) $(dumps)
	python ../../tools/elfhex.py -ab -s ./tmp/ -d ./hex/

%.o : %.c
	riscv32-unknown-elf-gcc $(CFLAGS) $< -o $@

%.o : %.S
	riscv32-unknown-elf-gcc $(CFLAGS) $< -o $@

%.elf: %.o
	riscv32-unknown-elf-ld $(LDFLAGS) $< -o $@

%.dump : %.elf
#riscv32-unknown-elf-objdump -D $< > $@
	riscv32-unknown-elf-strip -R .comment -R .riscv.attributes -o $< $<
	riscv32-unknown-elf-objdump -D $< > $@


clean:
	rm tmp/*.o tmp/*.hex tmp/*.mem tmp/*.dump tmp/*.elf