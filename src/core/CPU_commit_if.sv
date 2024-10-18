`include "CPU_define.vh"

interface CPU_commit_if ();

    logic wb;
    logic m;
    logic [VIRTUAL_ADDR_WIDTH] add_result;
    logic [REG_WIDTH] alu_result;
    logic zero;
    logic [REG_WIDTH] rb;

    modport master (
        output wb;
        output m;
        output add_result;
        output alu_result;
        output zero;
        output rb;
    );

    modport slave (
        input wb;
        input m;
        input add_result;
        input alu_result;
        input zero;
        input rb;
    );

endinterface