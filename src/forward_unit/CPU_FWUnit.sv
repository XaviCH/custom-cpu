`include "CPU_define.vh"

module CPU_FWUnit
(
    input wire clock,
    input wire reset,
    
    CPU_FWUnit_if.slave FWUnit_if
);

always @(posedge clock) begin
    if (reset) begin 
    end else begin
        //ra bypass
        if (FWUnit_if.ra_id == FWUnit_if.rd_wb && FWUnit_if.writeback_wb) begin
            FWUnit_if.ra_bypass <= 2;
        end else if (FWUnit_if.ra_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit) begin
            FWUnit_if.ra_bypass <= 1;
        end else begin
            FWUnit_if.ra_bypass <= 0;
        end
        //rb bypass
        if (FWUnit_if.rb_id == FWUnit_if.rd_wb && FWUnit_if.writeback_wb) begin
            FWUnit_if.rb_bypass <= 2;
        end else if (FWUnit_if.rb_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit) begin
            FWUnit_if.rb_bypass <= 1;
        end else begin
            FWUnit_if.rb_bypass <= 0;
        end
    end

end

endmodule