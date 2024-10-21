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
        if (FWUnit_input_if.ra_execute == FWUnit_input_if.reg_dest_commit && FWUnit_input_if.write_back_commit.mem_to_reg==0 && FWUnit_input_if.write_back_commit.reg_write==1) begin
            FWUnit_output_if.ra_from_commit = 1;
        end else begin
            //TODO ALL FORWARD UNIT STUFF
        end
    end

end

endmodule