PROJ_PATH = ../../..
BANK_PATH = $(PROJ_PATH)/src/bank_reg
FW_PATH = $(PROJ_PATH)/src/forward_unit
HD_PATH = $(PROJ_PATH)/src/hazard_det_unit
MUL_PATH = $(PROJ_PATH)/src/mul_unit
CORE_PATH = $(PROJ_PATH)/src/core

FLAGS = --binary -j 0 #-Wall
INCLUDES = -I$(PROJ_PATH)/src/
COMMON_FILES = $(BANK_PATH)/CPU_bank_reg_if $(FW_PATH)/CPU_FWUnit_if $(HD_PATH)/CPU_HDUnit_if $(MUL_PATH)/CPU_mul_unit_if $(CORE_PATH)/CPU_fetch_if $(CORE_PATH)/CPU_decode_if $(CORE_PATH)/CPU_execute_if $(CORE_PATH)/CPU_commit_if $(CORE_PATH)/CPU_writeback_if

.PHONY: all clean

CPU_full_core_tb.exe: CPU_full_core_tb.sv $(BANK_PATH)/CPU_bank_reg.sv $(FW_PATH)/CPU_FWUnit.sv $(HD_PATH)/CPU_HDUnit.sv $(MUL_PATH)/CPU_mul_unit.sv $(CORE_PATH)/CPU_fetch.sv $(CORE_PATH)/CPU_decode.sv $(CORE_PATH)/CPU_execute.sv $(CORE_PATH)/CPU_commit.sv $(CORE_PATH)/CPU_writeback.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

CPU_full_core_mul_tb.exe: CPU_full_core_mul_tb.sv $(BANK_PATH)/CPU_bank_reg.sv $(FW_PATH)/CPU_FWUnit.sv $(HD_PATH)/CPU_HDUnit.sv $(MUL_PATH)/CPU_mul_unit.sv $(CORE_PATH)/CPU_fetch.sv $(CORE_PATH)/CPU_decode.sv $(CORE_PATH)/CPU_execute.sv $(CORE_PATH)/CPU_commit.sv $(CORE_PATH)/CPU_writeback.sv
	verilator $(FLAGS) -o $@ $^ $(COMMON_FILES) $(INCLUDES)

all: CPU_full_core_tb.exe CPU_full_core_mul_tb.exe

clean:
	rm -rf obj_dir
