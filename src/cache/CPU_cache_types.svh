`ifndef CPU_CACHE_TYPES_SVH
`define CPU_CACHE_TYPES_SVH

`include "CPU_define.vh"

typedef enum logic [1:0] {
    WORD, HALF, BYTE
} cache_mode_e;

`endif