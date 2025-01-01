// CONFIG

`define NUM_REGS 32
`define NUM_CACHE_LINES 4

`define REG_WIDTH 32
`define INSTR_WIDTH 32
`define BYTE_WIDTH 8
`define HALF_WIDTH 16
`define WORD_WIDTH 32
`define LINE_WIDTH 128

`define BOOT_ADDR 'h1000 
`define EXCEPTION_ADDR 'h1000

`define MEMORY_BUS_LATENCY 5

`define VIRTUAL_ADDR_WIDTH 32
`define PHYSICAL_ADDR_WIDTH 20
`define PAGE_WIDTH 4096

`define NUM_ALU_OPS 3

//INS TYPE
`define R_TYPE_OP 'b00
`define M_TYPE_OP 'b01
`define B_TYPE_OP 'b11

// ALU OPS
`define ALU_ADD_OP 'b00
`define ALU_SUB_OP 'b01
`define ALU_MUL_OP 'b10

// ISA 

`define ISA_ADD_OP 'h0
`define ISA_SUB_OP 'h1
`define ISA_MUL_OP 'h2
`define ISA_LDB_OP 'h10
`define ISA_LDW_OP 'h11
`define ISA_STB_OP 'h12
`define ISA_STW_OP 'h13
`define ISA_MOV_OP 'h14
`define ISA_BEQ_OP 'h30
`define ISA_JUMP_OP 'h31

`define ISA_TLB_WRITE_OP 'h32
`define ISA_IRET_OP 'h33

// MEM 

`define MEM_LATENCY 5
`define MEM_SIZE 1024*1024 // 2^10 bytes
