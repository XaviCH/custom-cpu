
.PHONY: all clean

all:
	make -C bank_reg
	make -C decode
	make -C decode_alu
	make -C execute
	make -C forward_unit
	make -C writeback

clean:
	make clean -C bank_reg
	make clean -C decode
	make clean -C decode_alu
	make clean -C execute
	make clean -C forward_unit
	make clean -C writeback