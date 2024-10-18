`include "CPU_define.vh"

interface CPU_execute_fetch_if ();

    logic branch; 
    logic [`DATA_WIDTH] alu_result; 

    modport master (
        output branch,
        output alu_result,
    );

    modport slave (
        input branch,
        input alu_result,
    );

endinterface