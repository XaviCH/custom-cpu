`include "CPU_define.vh"

interface CPU_cache_response_if ();

    logic hit;
    logic [`WORD_WIDTH-1:0] data;
    logic [`PHYSICAL_ADDR_WIDTH-1:0] addr;

    modport master (
        output hit, data, addr
    );

    modport slave (
        input hit, data, addr
    );

endinterface
