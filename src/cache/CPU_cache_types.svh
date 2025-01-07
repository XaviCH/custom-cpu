`ifndef CPU_CACHE_TYPES_SVH
`define CPU_CACHE_TYPES_SVH

`include "CPU_define.vh"

typedef enum logic [1:0] {
    WORD, HALF, BYTE
} cache_mode_e;

typedef struct packed {
    logic raise;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] vaddr;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] pc;  
} tlb_exception_t;

`endif