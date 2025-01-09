`include "CPU_define.vh"

interface CPU_bank_reg_if ();

    wire [$clog2(`NUM_REGS)-1:0] read_reg_a;
    wire [$clog2(`NUM_REGS)-1:0] read_reg_b;
    wire [$clog2(`NUM_REGS)-1:0] write_reg;
    wire [`REG_WIDTH-1:0] write_data;
    wire write_enable;

    wire [$clog2(`NUM_REGS)-1:0] write_reg_mul;
    wire [`REG_WIDTH-1:0] write_data_mul;
    wire write_enable_mul;

    wire [`REG_WIDTH-1:0] read_data_a;
    wire [`REG_WIDTH-1:0] read_data_b;

    modport master_read (
        output read_reg_a,
        output read_reg_b,
        input read_data_a,
        input read_data_b
    );

    modport master_write (
        output write_reg,
        output write_data,
        output write_enable,
        output write_reg_mul,
        output write_data_mul,
        output write_enable_mul
    );

    modport slave (        
        input read_reg_a,
        input read_reg_b,
        input write_reg,
        input write_data,
        input write_enable,
        input write_reg_mul,
        input write_data_mul,
        input write_enable_mul,
        output read_data_a,
        output read_data_b
    );

endinterface
