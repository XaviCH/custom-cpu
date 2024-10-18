`include "CPU_define.vh"

interface CPU_writeback_if ();

    logic wb;
    logic [REG_WIDTH] read_data;
    logic [REG_WIDTH] alu_result;

    modport master (
        output wb,
        output read_data,
        output alu_result
    );

    modport slave (
        input wb,
        input read_data,
        input alu_result
    );

endinterface