`include "CPU_define.vh"

interface CPU_cache_response_if ();

    wire valid;
    wire [31:0] data;

    modport master (
        output valid, data
    );

    modport slave (
        input valid, data
    );

endinterface
