`include "CPU_define.vh"

interface CPU_FWUnit_input_if ();

    //INPUT
    wire [$clog2(NUM_REGS)] reg_dest_commit;
    wire [$clog2(NUM_REGS)] reg_dest_wb;
    writeback_t write_back_commit;
    writeback_t write_back_wb;

    modport master(
        input ra_execute,
        input rb_execute,
        input reg_dest_commit,
        input reg_dest_wb,
        input write_back_commit,
        input write_back_wb
    );

    modport slave (
        input ra_execute,
        input rb_execute,
        output reg_dest_commit,
        output reg_dest_wb,
        output write_back_commit,
        output write_back_wb
    );

endinterface