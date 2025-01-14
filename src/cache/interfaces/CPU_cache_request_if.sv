`include "CPU_define.vh"
`include "cache/CPU_cache_types.svh"

interface CPU_cache_request_if ();

    logic read, write;
    cache_mode_e mode;
    logic [`PHYSICAL_ADDR_WIDTH-1:0] addr;
    logic [`WORD_WIDTH-1:0] data;

    modport master (
        output read, write, mode, addr, data
    );

    modport slave (
        input read, write, mode, addr, data
    );

endinterface
