PROJ_PATH = ../../..
FW_PATH = $(PROJ_PATH)/src/forward_unit

FLAGS = --binary -j 0 #-Wall
INCLUDES = -I$(PROJ_PATH)/src/
COMMON_FILES = $(FW_PATH)/CPU_FWUnit_if

.PHONY: all clean

CPU_FW_unit_tb.exe: CPU_FW_unit_tb.sv $(FW_PATH)/CPU_FWUnit.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

all: CPU_FW_unit_tb.exe

clean:
	rm -rf obj_dir
