`ifndef CPU_MUL_UNIT_IF_SV
`define CPU_MUL_UNIT_IF_SV

`include "CPU_define.vh"

interface CPU_mul_unit_if ();

    wire [$clog2(`NUM_REGS)-1:0] rd_id;
    wire [`REG_WIDTH-1:0] ra_data;
    wire [`REG_WIDTH-1:0] rb_data;
    logic writeback_mul;

    typedef struct packed {
        logic writeback_mul;
        logic [$clog2(`NUM_REGS)-1:0] rd_id;
        logic [`REG_WIDTH-1:0] mul_result;
    } writeback_mul_t;

    writeback_mul_t mul_stages[`MUL_STAGES];
    
    modport master_decode(
        output writeback_mul
    );

    modport master_execute(
        output rd_id,
        output ra_data,
        output rb_data
    );
    modport slave (
        input rd_id,
        input ra_data,
        input rb_data,
        inout mul_stages,
        input writeback_mul
    );

endinterface

`endif
