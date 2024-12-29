PROJ_PATH = ../../..
BANK_PATH = $(PROJ_PATH)/src/bank_reg
CORE_PATH = $(PROJ_PATH)/src/core

FLAGS = --binary -j 0 #-Wall
INCLUDES = -I$(PROJ_PATH)/src/
COMMON_FILES = $(BANK_PATH)/CPU_bank_reg_if $(CORE_PATH)/CPU_writeback_if

.PHONY: all clean

CPU_writeback_tb.exe: CPU_writeback_tb.sv $(CORE_PATH)/CPU_writeback.sv $(BANK_PATH)/CPU_bank_reg.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

all: CPU_writeback_tb.exe

clean:
	rm -rf obj_dir
