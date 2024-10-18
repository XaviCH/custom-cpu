`include "CPU_define.vh"

interface MEM_core_response_if ();

    logic valid;
    logic [`LINE_WIDTH-1:0] line_data;

    modport master (
        output valid,
        output line_data
    );

    modport slave (
        input valid,
        input line_data
    );

endinterface
