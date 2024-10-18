`include "CPU_define.vh"

interface CPU_cache_mem_response_if ();

    wire valid;
    wire [`LINE_WIDTH-1:0] data;
    wire [`VIRTUAL_ADDR_WIDTH-1:0] addr;

    modport master (
        output valid, data, addr
    );

    modport slave (
        input valid, data, addr
    );

endinterface
