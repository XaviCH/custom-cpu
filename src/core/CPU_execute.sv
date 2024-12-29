module CPU_execute
(
    input wire clock,
    input wire reset,

    // input
    CPU_execute_if.slave execute_if,
    
    // CPU_FWUnit_input_if.master FWUnit_input_if,
    // CPU_FWUnit_output_if.slave FWUnit_output_if,
    
    // output
    CPU_commit_if.master commit_if
);

assign commit_if.reg_dest = execute_if.reg_dest;
assign commit_if.writeback = execute_if.writeback;
assign commit_if.commit = execute_if.commit;
assign commit_if.rb_data = execute_if.rb_data;
// assign FWUnit_input_if.ra_execute <= execute_if.ra_data;
// assign FWUnit_input_if.rb_execute <= execute_if.rb_data;

always @(posedge clock) begin
    if (reset) begin
        //TODO: reset 
    end else begin
        if (execute_if.execute.alu_op == `ISA_ADD_OP) begin
            if (execute_if.execute.reg_b) commit_if.alu_result <= execute_if.ra_data + execute_if.offset_data;
            else commit_if.alu_result <= execute_if.ra_data + execute_if.rb_data;
        end else if (execute_if.execute.alu_op == `ISA_SUB_OP) begin
            if (execute_if.execute.reg_b) commit_if.alu_result <= execute_if.ra_data - execute_if.offset_data;
            else commit_if.alu_result <= execute_if.ra_data - execute_if.rb_data;
        end
        if (commit_if.alu_result==0) begin
            commit_if.zero<='b1;
        end
    end
end
endmodule
