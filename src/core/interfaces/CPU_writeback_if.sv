`include "CPU_define.vh"

interface CPU_writeback_if ();

    typedef struct packed {
        logic mem_to_reg;
        logic reg_write;
    } writeback_t;

typedef struct packed {
    logic writeback_mul;
    logic [$clog2(`NUM_REGS)-1:0] rd_id;
    logic [`REG_WIDTH-1:0] mul_result;
} writeback_mul_t;

    writeback_t writeback;
    writeback_mul_t writeback_mul;

    logic [$clog2(`NUM_REGS)-1:0] reg_dest;
    logic [`REG_WIDTH-1:0] mem_data;
    logic [`REG_WIDTH-1:0] alu_data;

    modport master (
        output writeback,
        output reg_dest,
        output mem_data,
        output alu_data
    );

    modport master_mul (
        output writeback_mul
    );

    modport slave (
        input writeback,
        input writeback_mul,
        input reg_dest,
        input mem_data,
        input alu_data
    );

endinterface