`include "CPU_define.vh"

interface CPU_fetch_if ();

    logic [VIRTUAL_ADDR_WIDTH] PC;

    modport master (
        output PC
    );

    modport slave (
        input PC
    );

endinterface