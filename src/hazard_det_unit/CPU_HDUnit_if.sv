`include "CPU_define.vh"

interface CPU_HDUnit_if ();

    wire execute_mem_read;
    wire [$clog2(`NUM_REGS)-1:0] execute_rd;
    wire [$clog2(`NUM_REGS)-1:0] decode_ra;
    wire ra_use;
    wire [$clog2(`NUM_REGS)-1:0] decode_rb;
    wire rb_use;

    wire stall;

    modport master_execute(
        output execute_mem_read,
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
        output rb_use
    );

    modport slave (
        input execute_mem_read,
        input execute_rd,
        input decode_ra,
        input ra_use,
        input decode_rb,
        input rb_use,
        output stall
    );

endinterface