`ifndef CPU_HDUNIT_IF_SV
`define CPU_HDUNIT_IF_SV

`include "CPU_define.vh"

interface CPU_HDUnit_if ();

    //READ AFTER LOAD
    wire execute_mem_read;
    wire commit_mem_read;

    wire [$clog2(`NUM_REGS)-1:0] execute_rd;
    wire [$clog2(`NUM_REGS)-1:0] commit_rd;

    wire [$clog2(`NUM_REGS)-1:0] decode_ra;
    wire ra_use;
    wire [$clog2(`NUM_REGS)-1:0] decode_rb;
    wire rb_use;
    wire [$clog2(`NUM_REGS)-1:0] decode_rd;
    wire rd_use;

    //BRANCH HAZARD EXECUTE
    wire branch_decode;
    wire execute_wb;
    
    //JUMP HAZARD EXECUTE
    wire jump_decode;

    //MUL HAZARD
    typedef struct packed {
        logic write_back;
        logic [$clog2(`NUM_REGS)-1:0] rd_id;
    } mul_writeback_t;

    mul_writeback_t mul_wb[5];

    wire stall;

    wire stall_decode;

    wire cache_miss;

    wire E_stall, E_nop;

    modport master_fetch(
        input stall
    );

    modport master_decode(
        input stall,
        input E_stall, E_nop,
        output stall_decode,
        output decode_ra,
        output ra_use,
        output decode_rb,
        output rb_use,
        output decode_rd,
        output rd_use,
        output branch_decode,
        output jump_decode
    );

    modport master_execute(
        output execute_mem_read,
        output execute_wb,
        output execute_rd,
        output mul_wb
    );

    modport master_commit(
        output commit_mem_read,
        output commit_rd
    );

    modport slave (
        input execute_mem_read,
        input execute_rd,
        input decode_ra,
        input ra_use,
        input decode_rb,
        input rb_use,
        input decode_rd,
        input rd_use,
        input branch_decode,
        input jump_decode,
        input commit_mem_read,
        input commit_rd,
        input execute_wb,
        input mul_wb,
        input cache_miss,
        output stall,
        output E_stall, E_nop 
    );

endinterface

`endif
