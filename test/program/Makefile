PROJ_PATH = ../..

FLAGS = --binary -j 0 -Wall
INCLUDES = -I$(PROJ_PATH)/src/ -I$(PROJ_PATH)/

.PHONY: all clean

CPU_tb.exe: CPU_tb.sv
	verilator $(FLAGS) -o $@ $< $(COMMON_FILES) $(INCLUDES)

CPU_branch_tb.exe: CPU_branch_tb.sv
	verilator $(FLAGS) -o $@ $< $(COMMON_FILES) $(INCLUDES)

CPU_buffer_sum_tb.exe: CPU_buffer_sum_tb.sv
	verilator $(FLAGS) -o $@ $< $(COMMON_FILES) $(INCLUDES)

CPU_mem_copy_tb.exe: CPU_mem_copy_tb.sv
	verilator $(FLAGS) -o $@ $< $(COMMON_FILES) $(INCLUDES)

CPU_mul_tb.exe: CPU_mul_tb.sv
	verilator $(FLAGS) -o $@ $< $(COMMON_FILES) $(INCLUDES)

CPU_gemm_tb.exe: CPU_gemm_tb.sv
	verilator $(FLAGS) -o $@ $< $(COMMON_FILES) $(INCLUDES)

all: CPU_tb.exe CPU_branch_tb.exe CPU_buffer_sum_tb.exe CPU_mem_copy_tb.exe CPU_mul_tb.exe CPU_gemm_tb.exe

clean:
	rm -rf obj_dir
