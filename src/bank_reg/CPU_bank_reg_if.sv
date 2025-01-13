`ifndef CPU_BANK_REG_IF_SV
`define CPU_BANK_REG_IF_SV

`include "CPU_define.vh"

interface CPU_bank_reg_if ();

    wire [$clog2(`NUM_REGS)-1:0] read_reg_a;
    wire [$clog2(`NUM_REGS)-1:0] read_reg_b;

    typedef struct packed {
        logic write_enable;
        logic [$clog2(`NUM_REGS)-1:0] write_reg;
        logic [`REG_WIDTH-1:0] write_data;
    } writeback_t;

    typedef struct packed {
        logic write_enable_mul;
        logic [$clog2(`NUM_REGS)-1:0] write_reg_mul;
        logic [`REG_WIDTH-1:0] write_data_mul;
    } writeback_mul_t;

    writeback_t writeback;
    writeback_mul_t writeback_mul;

    wire [`REG_WIDTH-1:0] read_data_a;
    wire [`REG_WIDTH-1:0] read_data_b;

    modport master_read (
        output read_reg_a,
        output read_reg_b,
        input read_data_a,
        input read_data_b,
        input writeback,
        input writeback_mul

    );

    // modport master_write (
    //     output writeback,
    //     output writeback_mul
    // );

    modport master_execute (
        output writeback_mul
    );

    modport slave (        
        input read_reg_a,
        input read_reg_b,
        input writeback,     
        input writeback_mul,
        output read_data_a,
        output read_data_b
    );

endinterface

`endif
