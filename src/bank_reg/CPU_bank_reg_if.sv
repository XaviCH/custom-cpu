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
        output read_reg_a,
        output read_reg_b,
        output write_reg,
        output write_data,
        output write_enable,
        input read_data_a,
        input read_data_b
    );

    modport slave (        
        input read_reg_a,
        input read_reg_b,
        input write_reg,
        input write_data,
        input write_enable,
        output read_data_a,
        output read_data_b
    );

endinterface
