`include "CPU_define.vh"

interface CPU_bank_reg_if ();

    wire [$clog2(`NUM_REGS)-1:0] read_reg_a;
    wire [$clog2(`NUM_REGS)-1:0] read_reg_b;
    wire [$clog2(`NUM_REGS)-1:0] write_reg;
    wire [`REG_WIDTH-1:0] write_data;
    wire write_enable;

    wire [`REG_WIDTH-1:0] read_data_a;
    wire [`REG_WIDTH-1:0] read_data_b;

    modport master (
        input read_reg_a,
        input read_reg_b,
        input write_reg,
        input write_data,
        input write_enable
    );

    modport slave (
        output read_data_a,
        output read_data_b
    );

endinterface
