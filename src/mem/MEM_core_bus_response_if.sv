`include "CPU_define.vh"

interface MEM_core_bus_response_if ();

    localparam LINE_ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH - $clog2(`LINE_WIDTH/`BYTE_WIDTH);

    logic id;
    logic valid;
    logic [LINE_ADDR_WIDTH-1:0] addr;
    logic [`LINE_WIDTH-1:0] data;

    modport master (
        output valid, id, addr, data
    );

    modport slave (
        input valid, id, addr, data
    );

endinterface
