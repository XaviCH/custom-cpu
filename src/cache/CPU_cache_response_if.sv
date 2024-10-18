`include "CPU_define.vh"

interface CPU_cache_response_if ();

    logic valid;
    logic word[32];

    modport master (
        output valid;
        output word;
    );

    modport slave (
        input valid;
        input word;
    );

endinterface