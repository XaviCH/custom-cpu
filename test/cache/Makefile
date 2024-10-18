PROJ_PATH = ../..
CACHE_PATH = $(PROJ_PATH)/src/cache

FLAGS = --binary -j 0
INCLUDES = -I$(PROJ_PATH)/src/
COMMON_FILES = \
	$(CACHE_PATH)/CPU_cache_request_if $(CACHE_PATH)/CPU_cache_response_if \
	$(CACHE_PATH)/CPU_cache_mem_request_if $(CACHE_PATH)/CPU_cache_mem_response_if

.PHONY: all clean

CPU_cache_tb.exe: CPU_cache_tb.sv $(CACHE_PATH)/CPU_cache.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

all: CPU_cache_tb.exe

clean:
	rm -rf obj_dir
