`ifndef CPU_FWUNIT_IF_SV
`define CPU_FWUNIT_IF_SV

`include "CPU_define.vh"

interface CPU_FWUnit_if ();

    wire [$clog2(`NUM_REGS)-1:0] ra_execute_id;
    wire [$clog2(`NUM_REGS)-1:0] rb_execute_id;

    wire [$clog2(`NUM_REGS)-1:0] ra_decode_id;
    wire [$clog2(`NUM_REGS)-1:0] rb_decode_id;

    wire [$clog2(`NUM_REGS)-1:0] rd_commit;
    wire [`REG_WIDTH-1:0] commit_value;
    wire writeback_commit;

    wire [$clog2(`NUM_REGS)-1:0] rd_wb;
    wire [`REG_WIDTH-1:0] wb_value;
    wire writeback_wb;

    wire [$clog2(`NUM_REGS)-1:0] rd_wb_mul;
    wire [`REG_WIDTH-1:0] wb_value_mul;
    wire writeback_wb_mul;

    wire [1:0] ra_decode_bypass;
    wire [1:0] rb_decode_bypass;

    wire [1:0] ra_execute_bypass;
    wire [1:0] rb_execute_bypass;

    wire ra_decode_bypass_mul;
    wire rb_decode_bypass_mul;
    
    wire ra_execute_bypass_mul;
    wire rb_execute_bypass_mul;

    modport master_decode(
        input ra_decode_bypass,
        input rb_decode_bypass,
        input ra_decode_bypass_mul,
        input rb_decode_bypass_mul,
        input commit_value,
        input wb_value,
        input wb_value_mul,
        output ra_decode_id,
        output rb_decode_id
    );

    modport master_execute(
        input ra_execute_bypass,
        input rb_execute_bypass,
        input ra_execute_bypass_mul,
        input rb_execute_bypass_mul,
        input commit_value,
        input wb_value,
        input wb_value_mul,
        output ra_execute_id,
        output rb_execute_id
    );

    modport master_commit(
        output rd_commit,
        output writeback_commit,
        output commit_value
    );

    modport master_writeback(
        output rd_wb,
        output writeback_wb,
        output wb_value,
        output rd_wb_mul,
        output writeback_wb_mul,
        output wb_value_mul
    );

    modport slave (
        input ra_decode_id,
        input rb_decode_id,
        input ra_execute_id,
        input rb_execute_id,
        input rd_commit,
        input writeback_commit,
        input rd_wb,
        input rd_wb_mul,
        input writeback_wb,
        input writeback_wb_mul,
        output ra_decode_bypass,
        output rb_decode_bypass,    
        output ra_decode_bypass_mul,
        output rb_decode_bypass_mul,
        output ra_execute_bypass,
        output rb_execute_bypass,
        output ra_execute_bypass_mul,        
        output rb_execute_bypass_mul
    );

endinterface

`endif
