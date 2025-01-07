`include "CPU_define.vh"

interface MEM_core_response_if ();

    localparam LINE_ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH - $clog2(`LINE_WIDTH/`BYTE_WIDTH);
    
    logic valid;
    logic [LINE_ADDR_WIDTH-1:0] addr;
    logic [`LINE_WIDTH-1:0] data;

    modport master (
        output valid, addr, data
    );

    modport slave (
        input valid, addr, data
    );

endinterface
