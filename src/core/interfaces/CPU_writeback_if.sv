`include "CPU_define.vh"

interface CPU_writeback_if ();

    typedef struct packed {
        logic mem_to_reg;
        logic reg_write;
    } writeback_t;

    writeback_t writeback;

    logic [$clog2(`NUM_REGS)-1:0] reg_dest;
    logic [`REG_WIDTH-1:0] mem_data;
    logic [`REG_WIDTH-1:0] alu_data;

    modport master (
        output writeback,
        output reg_dest,
        output mem_data,
        output alu_data
    );

    modport slave (
        input writeback,
        output reg_dest,
        input mem_data,
        input alu_data
    );

endinterface