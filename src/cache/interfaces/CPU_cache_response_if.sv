`include "CPU_define.vh"

interface CPU_cache_response_if ();

    logic hit;
    logic [`WORD_WIDTH-1:0] data;
    /* verilator lint_off UNUSEDSIGNAL */
    /* verilator lint_off UNDRIVEN */
    logic [`PHYSICAL_ADDR_WIDTH-1:0] addr;
    /* verilator lint_on UNDRIVEN */
    /* verilator lint_on UNUSEDSIGNAL */

    modport master (
        output hit, data, addr
    );

    modport slave (
        input hit, data, addr
    );

endinterface
