`include "CPU_define.vh"

interface CPU_mul_unit_if ();

    logic stage_wb;
    logic [$clog2(`NUM_REGS)-1:0] rd_id;
    logic [`REG_WIDTH-1:0] ra_data;
    logic [`REG_WIDTH-1:0] rb_data;
    
    modport master(
        output ra_data,
        output rb_data
    );

    modport slave (
        input ra_data,
        input rb_data
    );

endinterface