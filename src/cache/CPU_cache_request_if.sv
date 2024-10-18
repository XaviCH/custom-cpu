`include "CPU_define.vh"

interface CPU_cache_request_if ();

    typedef struct packed {
        logic [2] byte;
        logic [2] word;
        logic [2] line;
        logic [26] _;
    } data_t;

    data_t addr;

    modport master (
        output data
    );

    modport slave (
        input data
    );

endinterface