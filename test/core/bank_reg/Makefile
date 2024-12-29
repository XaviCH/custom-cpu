PROJ_PATH = ../..
BANK_PATH = $(PROJ_PATH)/src/bank_reg

FLAGS = --binary -j 0 -Wall
INCLUDES = -I$(PROJ_PATH)/src/
COMMON_FILES = $(BANK_PATH)/CPU_bank_reg_if

.PHONY: all clean

CPU_bank_reg_tb.exe: CPU_bank_reg_tb.sv $(BANK_PATH)/CPU_bank_reg.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

all: CPU_bank_reg_tb.exe

clean:
	rm -rf obj_dir
