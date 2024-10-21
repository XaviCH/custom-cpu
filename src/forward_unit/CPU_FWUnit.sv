`include "CPU_define.vh"

module CPU_FWUnit;
(
    input wire clock,
    input wire reset,
    
    //input
    CPU_FWUnit_input_if.slave FWUnit_input_if,

    // ouput
    CPU_FWUnit_output_if.master FWUnit_output_if
);

always @(posedge clock) begin
    if (reset) begin 
    end else begin
        // TODO
    end

end

endmodule