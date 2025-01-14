PROJ_PATH = ../../..
BANK_PATH = $(PROJ_PATH)/src/bank_reg
CORE_PATH = $(PROJ_PATH)/src/core

FLAGS = --binary -j 0 #-Wall
INCLUDES = -I$(PROJ_PATH)/src/
COMMON_FILES = $(BANK_PATH)/CPU_bank_reg_if $(CORE_PATH)/CPU_decode_if $(CORE_PATH)/CPU_execute_if

.PHONY: all clean

CPU_decode_tb.exe: CPU_decode_tb.sv $(CORE_PATH)/CPU_decode.sv $(BANK_PATH)/CPU_bank_reg.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

all: CPU_decode_tb.exe

clean:
	rm -rf obj_dir
