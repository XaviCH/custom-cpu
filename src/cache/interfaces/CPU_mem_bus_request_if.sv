`include "CPU_define.vh"

interface CPU_mem_bus_request_if #(
    LINE_WIDTH = `LINE_WIDTH
) ();

    localparam MEM_ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH - $clog2(`LINE_WIDTH/`BYTE_WIDTH);

    logic read, write;
    logic [LINE_WIDTH-1:0] data;
    logic [MEM_ADDR_WIDTH-1:0] addr;

    modport master (
        output read, write, data, addr
    );

    modport slave (
        input read, write, data, addr
    );

endinterface
