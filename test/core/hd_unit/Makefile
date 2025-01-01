PROJ_PATH = ../../..
HD_PATH = $(PROJ_PATH)/src/hazard_det_unit

FLAGS = --binary -j 0 #-Wall
INCLUDES = -I$(PROJ_PATH)/src/
COMMON_FILES = $(HD_PATH)/CPU_HDUnit_if

.PHONY: all clean

CPU_HD_unit_tb.exe: CPU_HD_unit_tb.sv $(HD_PATH)/CPU_HDUnit.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

all: CPU_HD_unit_tb.exe

clean:
	rm -rf obj_dir
