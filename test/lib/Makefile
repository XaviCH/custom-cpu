PROJ_PATH = ../..
LIB_PATH = $(PROJ_PATH)/src/lib

FLAGS = --binary -j 0 -Wall
INCLUDES = -I$(PROJ_PATH)/src/
COMMON_FILES = 

.PHONY: all clean

MOD_decoded_counter_tb.exe: MOD_decoded_counter_tb.sv $(LIB_PATH)/MOD_decoded_counter.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

MOD_find_first_match_tb.exe: MOD_find_first_match_tb.sv $(LIB_PATH)/MOD_find_first_match.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

all: MOD_decoded_counter_tb.exe MOD_find_first_match_tb.exe

clean:
	rm -rf obj_dir
