`include "CPU_define.vh"

interface CPU_FWUnit_if ();

    wire [$clog2(`NUM_REGS)-1:0] ra_id;
    wire [$clog2(`NUM_REGS)-1:0] rb_id;

    wire [$clog2(`NUM_REGS)-1:0] rd_commit;
    wire [`REG_WIDTH-1:0] commit_value;
    wire writeback_commit;

    wire [$clog2(`NUM_REGS)-1:0] rd_wb;
    wire [`REG_WIDTH-1:0] wb_value;
    wire writeback_wb;

    wire [1:0] ra_bypass;
    wire [1:0] rb_bypass;


    modport master_execute(
        input ra_bypass,
        input rb_bypass,
        input commit_value,
        input wb_value,
        output ra_id,
        output rb_id
    );

    modport master_commit(
        output rd_commit,
        output writeback_commit,
        output commit_value
    );

    modport master_writeback(
        output rd_wb,
        output writeback_wb,
        output wb_value
    );

    modport slave (
        input ra_id,
        input rb_id,
        input rd_commit,
        input writeback_commit,
        input rd_wb,
        input writeback_wb,
        output ra_bypass,
        output rb_bypass,        
        output commit_value,
        output wb_value
    );

endinterface