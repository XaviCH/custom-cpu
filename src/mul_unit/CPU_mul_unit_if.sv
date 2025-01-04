`include "CPU_define.vh"

interface CPU_mul_unit_if ();

    wire [$clog2(`NUM_REGS)-1:0] rd_id;
    wire [`REG_WIDTH-1:0] ra_data;
    wire [`REG_WIDTH-1:0] rb_data;
    logic writeback_mul;
    
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
        input writeback_mul
    );

endinterface