`ifndef CPU_TYPES_VH
`define CPU_TYPES_VH

`include "CPU_define.vh"
`include "cache/CPU_cache_types.svh"

typedef logic [`BYTE_WIDTH-1:0] byte_t;

typedef struct packed {
    byte_t [`HALF_WIDTH/`BYTE_WIDTH-1:0] as_bytes;
} half_t;

typedef union {
    byte_t  [`WORD_WIDTH/`BYTE_WIDTH-1:0]   as_bytes;
    half_t  [`WORD_WIDTH/`HALF_WIDTH-1:0]   as_halfs;
    logic   [`WORD_WIDTH-1:0]               as_word;
} word_t;

typedef union {
    byte_t  [`LINE_WIDTH/`BYTE_WIDTH-1:0]   as_bytes;
    half_t  [`LINE_WIDTH/`HALF_WIDTH-1:0]   as_halfs;
    word_t  [`LINE_WIDTH/`WORD_WIDTH-1:0]   as_words;
    logic   [`LINE_WIDTH-1:0]               as_line;
} line_t;

typedef struct packed {
    logic mem_write;
    logic mem_read;
    cache_mode_e mode;
} CPU_commit_request_t;

`endif
