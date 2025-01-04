`include "CPU_define.vh"

interface CPU_mem_bus_response_if ();

    localparam MEM_ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH - $clog2(`LINE_WIDTH/`BYTE_WIDTH);

    logic valid;
    line_t data;
    logic [MEM_ADDR_WIDTH-1:0] addr;

    modport master (
        output valid, data, addr
    );

    modport slave (
        input valid, data, addr
    );

endinterface
