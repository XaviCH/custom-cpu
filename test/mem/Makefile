PROJ_PATH = ../..
MEM_PATH = $(PROJ_PATH)/src/mem

FLAGS = --binary -j 0 -Wall
INCLUDES = -I$(PROJ_PATH)/src/
COMMON_FILES = $(MEM_PATH)/MEM_core_request_if $(MEM_PATH)/MEM_core_response_if

.PHONY: all clean

MEM_core_tb.exe: MEM_core_tb.sv $(MEM_PATH)/MEM_core.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

MEM_core_bus_tb.exe: MEM_core_bus_tb.sv $(MEM_PATH)/MEM_core_bus.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

all: MEM_core_tb.exe MEM_core_bus_tb.exe

clean:
	rm -rf obj_dir
