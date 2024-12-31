`include "CPU_define.vh"

module CPU_commit
(
    input wire clock,
    input wire reset,

    // input
    CPU_commit_if.slave commit_if,
    CPU_FWUnit_if.master_commit FWUnit_if,
    //output
    CPU_writeback_if.master writeback_if
);

assign writeback_if.writeback = commit_if.writeback;
assign writeback_if.alu_data = commit_if.alu_result;
assign writeback_if.reg_dest = commit_if.reg_dest;

assign FWUnit_if.rd_commit = commit_if.reg_dest;
assign FWUnit_if.writeback_commit = commit_if.writeback.reg_write;

//ALL MEMORY LOGIC

endmodule
