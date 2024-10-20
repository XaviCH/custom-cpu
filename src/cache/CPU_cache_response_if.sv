`include "CPU_define.vh"

interface CPU_cache_response_if ();

    logic hit;
    logic [31:0] data;

    modport master (
        output hit, data
    );

    modport slave (
        input hit, data
    );

endinterface
