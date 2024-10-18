// CONFIG

`define NUM_REGS 32
`define NUM_CACHE_LINES 4

`define REG_WIDTH 32
`define INSTR_WIDTH 32
`define LINE_WIDTH 128

`define BOOT_ADDR 'h1000 
`define EXCEPTION_ADDR 'h1000

`define MEMORY_BUS_LATENCY 5

`define VIRTUAL_ADDR_WIDTH 32
`define PHYSICAL_ADDR_WIDTH 20
`define PAGE_WIDTH 4096

`define NUM_ALU_OPS 3

// ALU OPS
`define ALU_ADD_OP 'b00
`define ALU_SUB_OP 'b01
`define ALU_MUL_OP 'b10

// ISA 

`define ISA_ADD_OP 'b0000
`define ISA_SUB_OP 'b0001
`define ISA_MUL_OP 'b0010
`define ISA_LDB_OP
`define ISA_LDW_OP
`define ISA_STB_OP
`define ISA_STW_OP
`define ISA_BEQ_OP
`define ISA_JUMP_OP

// MEM 

`define MEM_LATENCY 5
`define MEM_SIZE 1024*1024