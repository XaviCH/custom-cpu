`include "CPU_define.vh"

module CPU_commit
(
    input wire clock,
    input wire reset,

    // input
    CPU_commit_if.slave commit_if,
    CPU_FWUnit_if.master_commit FWUnit_if,
    CPU_HDUnit_if.master_commit HDUnit_if,
    //output
    CPU_writeback_if.master writeback_if
);

assign FWUnit_if.rd_commit = commit_if.reg_dest;
assign FWUnit_if.writeback_commit = commit_if.writeback.reg_write;
assign FWUnit_if.commit_value = commit_if.alu_result;

assign HDUnit_if.commit_mem_read=commit_if.commit.mem_read;
assign HDUnit_if.commit_rd=commit_if.reg_dest;

always @(posedge clock) begin
    if (reset) begin
        //TODO: reset 
    end else begin
        //PASS VALUES
        writeback_if.writeback <= commit_if.writeback;
        writeback_if.alu_data <= commit_if.alu_result;
        writeback_if.reg_dest <= commit_if.reg_dest;
        //ALL MEMORY LOGIC
    end
end
endmodule
