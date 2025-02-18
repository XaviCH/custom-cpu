`ifndef CPU_MEM_BUS_RESPONSE_SV
`define CPU_MEM_BUS_RESPONSE_SV

`include "CPU_define.vh"

interface CPU_mem_bus_response_if #(
    LINE_WIDTH = `LINE_WIDTH
) ();

    localparam MEM_ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH - $clog2(`LINE_WIDTH/`BYTE_WIDTH);

    logic valid;
    logic [LINE_WIDTH-1:0] data;
    /* verilator lint_off UNUSEDSIGNAL */
    /* verilator lint_off UNDRIVEN */
    logic [MEM_ADDR_WIDTH-1:0] addr;
    /* verilator lint_on UNDRIVEN */
    /* verilator lint_on UNUSEDSIGNAL */
    
    modport master (
        output valid, data, addr
    );

    modport slave (
        input valid, data, addr
    );

endinterface

`endif
