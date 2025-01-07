PROJ_PATH = ../..
CACHE_PATH = $(PROJ_PATH)/src/cache
LIB_PATH = $(PROJ_PATH)/src/lib
CACHE_INTERFACES_PATH = $(CACHE_PATH)/interfaces

FLAGS = --binary -j 0
INCLUDES = -I$(PROJ_PATH)/src/ -I$(PROJ_PATH)
# COMMON_FILES = \
	$(CACHE_INTERFACES_PATH)/CPU_cache_request_if $(CACHE_INTERFACES_PATH)/CPU_cache_response_if \
	$(CACHE_INTERFACES_PATH)/CPU_cache_mem_request_if $(CACHE_INTERFACES_PATH)/CPU_cache_mem_response_if

.PHONY: all clean

CPU_cache_tb.exe: CPU_cache_tb.sv $(CACHE_PATH)/CPU_cache.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

CPU_storebuffer_tb.exe: CPU_storebuffer_tb.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

CPU_tlb_tb.exe: CPU_tlb_tb.sv
	verilator $(FLAGS) -o $@ $< $(INCLUDES)

all: CPU_cache_tb.exe CPU_storebuffer_tb.exe

clean:
	rm -rf obj_dir
