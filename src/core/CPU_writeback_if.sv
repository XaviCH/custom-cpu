`include "CPU_define.vh"

interface CPU_writeback_if ();

    typedef struct packed {
        logic mem_to_reg;
        logic reg_write;
    } writeback_t;

    writeback_t write_back;

    logic [$clog2(NUM_REGS)] reg_dest;
    logic [REG_WIDTH] mem_data;
    logic [REG_WIDTH] alu_data;

    modport master (
        output write_reg_file,
        output alu_mem,
        output mem_data,
        output alu_data
    );

    modport slave (
        input write_reg_file,
        output alu_mem,
        input mem_data,
        input alu_data
    );

endinterface