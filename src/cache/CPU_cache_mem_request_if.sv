`include "CPU_define.vh"

interface CPU_cache_mem_request_if ();

    typedef struct packed {
        logic [25:0] _;
        logic [1:0] line;
        logic [1:0] word;
        logic [1:0] _byte;
    } addr_t;

    wire read, write;
    wire [31:0] data;
    wire addr_t addr;

    modport master (
        output read, write, data, addr
    );

    modport slave (
        input read, write, data, addr
    );

endinterface
