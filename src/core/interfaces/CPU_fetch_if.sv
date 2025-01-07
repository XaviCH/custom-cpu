`include "CPU_define.vh"

interface CPU_fetch_if ();

    logic tlb_enable, tlb_write;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] tlb_addr;
    logic [`PHYSICAL_ADDR_WIDTH-1:0] tlb_data;

    logic [`PHYSICAL_ADDR_WIDTH-1:0] pc;
    logic exception;

    modport request (
        input tlb_enable, tlb_write, tlb_addr, tlb_data,
        input pc, exception
    );

    logic tlb_hit;

    logic [`INSTR_WIDTH-1:0] instr;
    logic cache_hit;
    logic [`PHYSICAL_ADDR_WIDTH-1:0] next_pc;

    modport response (
        output tlb_hit,
        output instr, cache_hit, next_pc
    );

endinterface