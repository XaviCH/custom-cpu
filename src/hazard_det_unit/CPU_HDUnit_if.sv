`include "CPU_define.vh"

interface CPU_HDUnit_if ();

    //READ AFTER LOAD
    wire execute_mem_read;
    wire [$clog2(`NUM_REGS)-1:0] execute_rd;
    wire [$clog2(`NUM_REGS)-1:0] decode_ra;
    wire ra_use;
    wire [$clog2(`NUM_REGS)-1:0] decode_rb;
    wire rb_use;

    //BRANCH HAZARD EXECUTE
    wire branch_decode;
    wire execute_wb;
    
    //JUMP HAZARD EXECUTE
    wire jump_decode;

    wire stall;

    modport master_execute(
        output execute_mem_read,
        output execute_wb,
        output execute_rd
    );

    modport master_fetch(
        input stall
    );

    modport master_decode(
        input stall,
        output decode_ra,
        output ra_use,
        output decode_rb,
        output rb_use,
        output branch_decode,
        output jump_decode
    );

    modport slave (
        input execute_mem_read,
        input execute_rd,
        input decode_ra,
        input ra_use,
        input decode_rb,
        input rb_use,
        input branch_decode,
        input jump_decode,
        input execute_wb,
        output stall
    );

endinterface