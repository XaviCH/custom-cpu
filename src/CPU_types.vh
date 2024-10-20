`include "CPU_define.vh"

typedef union logic [`LINE_WIDTH] {
    [`LINE_WIDTH/`BYTE_WIDTH][`BYTE_WIDTH-1:0] _byte;
    [`LINE_WIDTH/`HALF_WIDTH][`HALF_WIDTH-1:0] half;
    [`LINE_WIDTH/`WORD_WIDTH][`WORD_WIDTH-1:0] word;
} line_t;

