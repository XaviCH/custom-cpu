`include "CPU_define.vh"

interface CPU_bank_reg_if ();

    wire [$clog2(NUM_REGS)] read_reg_a;
    wire [$clog2(NUM_REGS)] read_reg_b;
    wire [$clog2(NUM_REGS)] write_reg;
    wire [REG_WIDTH] write_data;
    wire write_enable;

    wire [REG_WIDTH] read_data_a;
    wire [REG_WIDTH] read_data_b;

    modport master_read (
        output read_reg_a,
        output read_reg_b
    );

    modport master_write (
        output write_reg,
        output write_data,
        output write_enable
    );

    modport slave (
        input read_data_a,
        input read_data_b
    );

endinterface