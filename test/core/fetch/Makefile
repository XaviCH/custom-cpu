PROJ_PATH = ../../..
CORE_PATH = $(PROJ_PATH)/src/core

FLAGS = --binary -j 0 #-Wall
INCLUDES = -I$(PROJ_PATH)/src/
COMMON_FILES = $(CORE_PATH)/CPU_decode_if $(CORE_PATH)/CPU_commit_if

.PHONY: all clean

CPU_fetch_tb.exe: CPU_fetch_tb.sv $(CORE_PATH)/CPU_fetch.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

all: CPU_fetch_tb.exe

clean:
	rm -rf obj_dir
