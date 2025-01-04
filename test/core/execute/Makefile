PROJ_PATH = ../../..
CORE_PATH = $(PROJ_PATH)/src/core

FLAGS = --binary -j 0 #-Wall
INCLUDES = -I$(PROJ_PATH)/src/
COMMON_FILES = $(CORE_PATH)/CPU_execute_if $(CORE_PATH)/CPU_commit_if

.PHONY: all clean

CPU_execute_tb.exe: CPU_execute_tb.sv $(CORE_PATH)/CPU_execute.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

all: CPU_execute_tb.exe

clean:
	rm -rf obj_dir
