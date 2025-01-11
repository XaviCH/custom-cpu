PROJ_PATH = ../../..
CACHE_PATH = $(PROJ_PATH)/src/cache
LIB_PATH = $(PROJ_PATH)/src/lib
CACHE_INTERFACES_PATH = $(CACHE_PATH)/interfaces

FLAGS = --binary -j 0
INCLUDES = -I$(PROJ_PATH)/src/ -I$(PROJ_PATH)
# COMMON_FILES = \
	$(CACHE_INTERFACES_PATH)/CPU_cache_request_if $(CACHE_INTERFACES_PATH)/CPU_cache_response_if \
	$(CACHE_INTERFACES_PATH)/CPU_cache_mem_request_if $(CACHE_INTERFACES_PATH)/CPU_cache_mem_response_if

.PHONY: all clean

CPU_commit_tb.exe: CPU_commit_tb.sv
	verilator $(FLAGS) -o $@ $< $(INCLUDES)

all: CPU_commit_tb.exe

clean:
	rm -rf obj_dir
