`include "CPU_define.vh"

interface MEM_core_request_if ();

    localparam LINE_ADDR_WIDTH = PHYSICAL_ADDR_WIDTH - LINE_WIDTH;

    logic read;
    logic write;
    logic [LINE_ADDR_WIDTH] line_addr;
    logic [LINE_WIDTH] line_data;

    modport master (
        output read;
        output write;
        output line_addr;
        output line_data;
    );

    modport slave (
        input read;
        input write;
        input line_addr;
        input line_data;
    );

endinterface