module CPU_execute;
(
    input wire clock,
    input wire reset,

    // input
    CPU_execute_if.slave execute_if,
    
    CPU_FWUnit_input_if.master FWUnit_input_if,
    CPU_FWUnit_output_if.slave FWUnit_output_if,
    
    // output
    CPU_commit_if.master commit_if,
);

assign commit_if.reg_dest <= execute_if.reg_dest;
assign FWUnit_input_if.ra_execute <= execute_if.ra_data;
assign FWUnit_input_if.rb_execute <= execute_if.rb_data;

always @(posedge clock) begin
    if (reset) begin 
    end else begin
        if (idle_reg == 0)
        begin
            if (execute_if.execute.alu_op == ISA_ADD_OP) begin
                commit_if.alu_result <= execute_if.ra_data + execute_if.rb_data;
                commit_if.writeback <= execute_if.writeback;
                commit_if.commit <= execute_if.commit;
            end else if (execute_if.execute.alu_op == ISA_SUB_OP) begin
                commit_if.alu_result <= execute_if.ra_data - execute_if.rb_data;
                commit_if.writeback <= execute_if.writeback;
                commit_if.commit <= execute_if.commit;
            end else if (decode_if.instr[31:28] == ISA_MUL_OP) begin
                commit_if.alu_result <= execute_if.ra_data * execute_if.rb_data;
                commit_if.writeback <= execute_if.writeback;
                commit_if.commit <= execute_if.commit;
                idle_reg <= 4;
            end
        end else begin
                idle_reg <= idle_reg - 1;
                commit_if.commit <= 0;
                commit_if.writeback.reg_write <= 0;
        end
    end
end


endmodule