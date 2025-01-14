`ifndef MEM_CORE_REQUEST_IF_SV
`define MEM_CORE_REQUEST_IF_SV

`include "CPU_define.vh"

interface MEM_core_request_if ();

    localparam LINE_ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH - $clog2(`LINE_WIDTH/`BYTE_WIDTH);

    logic read;
    logic write;
    logic [LINE_ADDR_WIDTH-1:0] addr;
    logic [`LINE_WIDTH-1:0] data;

    modport master (
        output read, write, addr, data
    );

    modport slave (
        input read, write, addr, data
    );

endinterface

`endif
