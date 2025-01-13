`ifndef CPU_COMMIT_IF_SV
`define CPU_COMMIT_IF_SV

`include "CPU_define.vh"
`include "cache/CPU_cache_types.svh"

interface CPU_commit_if ();

    typedef struct packed {
        logic mem_write;
        logic mem_read;
    } commit_t;

    typedef struct packed {
        logic mem_to_reg;
        logic reg_write;
    } writeback_t;

    commit_t commit;
    writeback_t writeback;
    logic [`REG_WIDTH-1:0] alu_result;
    logic [`REG_WIDTH-1:0] rb_data;
    //TYPE_M y TYPE_R
    logic [$clog2(`NUM_REGS)-1:0] reg_dest;

    //BRANCH
    logic zero;

    // TLB logic
    logic tlb_enable, tlb_write;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] tlb_addr;
    logic [`PHYSICAL_ADDR_WIDTH-1:0] tlb_data;
    // Cache logic
    logic cache_write, cache_read;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] cache_addr;
    logic [`REG_WIDTH-1:0] cache_data_in;
    cache_mode_e cache_mode;


    modport master (
        output commit,
        output writeback,
        output alu_result,
        output zero,
        output rb_data,
        output reg_dest
    );

    modport request (
        input tlb_enable, tlb_write, tlb_addr, tlb_data,
        input cache_write, cache_read, cache_mode, cache_addr, cache_data_in
    );

    logic tlb_hit;

    logic cache_hit;
    logic [`WORD_WIDTH-1:0] cache_data_out;

    modport response (
        output tlb_hit,
        output cache_hit, cache_data_out
    );

endinterface

`endif
