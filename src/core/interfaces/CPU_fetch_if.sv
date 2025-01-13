`ifndef CPU_FETCH_IF_SV
`define CPU_FETCH_IF_SV

`include "CPU_define.vh"

interface CPU_fetch_if ();

    logic tlb_enable, tlb_write;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] tlb_addr;
    logic [`PHYSICAL_ADDR_WIDTH-1:0] tlb_data;

    logic [`VIRTUAL_ADDR_WIDTH-1:0] pc;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] jump_pc;
    logic jump;
    logic exception;

    modport request (
        input tlb_enable, tlb_write, tlb_addr, tlb_data,
        input pc, exception, jump, jump_pc
    );

    logic tlb_hit;

    logic [`INSTR_WIDTH-1:0] instr;
    logic cache_hit;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] next_pc;

    modport response (
        output tlb_hit,
        output instr, cache_hit, next_pc
    );

    modport decode_req (
        output jump, jump_pc
    );
        

endinterface

`endif
