`include "CPU_define.vh"

interface CPU_fetch_if ();

    wire change_PC;
    wire [`VIRTUAL_ADDR_WIDTH-1:0] new_PC;

    modport master (
        output change_PC,
        output new_PC
    );

    modport slave (
        input change_PC,
        input new_PC
    );

endinterface