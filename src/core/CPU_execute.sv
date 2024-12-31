module CPU_execute
(
    input wire clock,
    input wire reset,

    // input
    CPU_execute_if.slave execute_if,
    
    // output
    CPU_FWUnit_if.master_execute FWUnit_if,
    CPU_commit_if.master commit_if
);

wire [`REG_WIDTH-1:0] ra_value;
wire [`REG_WIDTH-1:0] rb_value;

assign FWUnit_if.ra_id = execute_if.ra_id;
assign FWUnit_if.rb_id = execute_if.rb_id;

assign ra_value = (FWUnit_if.ra_bypass[1] ? FWUnit_if.commit_value : (FWUnit_if.ra_bypass[0] ? FWUnit_if.wb_value : execute_if.ra_data));
assign rb_value = (execute_if.execute.use_reg_b ? (FWUnit_if.rb_bypass[1] ? FWUnit_if.commit_value : (FWUnit_if.rb_bypass[0] ? FWUnit_if.wb_value : execute_if.rb_data)) : execute_if.offset_data);

always @(posedge clock) begin
    if (reset) begin
        //TODO: reset 
    end else begin
        //PASS VALUES
        commit_if.reg_dest <= execute_if.reg_dest;
        commit_if.writeback <= execute_if.writeback;
        commit_if.commit <= execute_if.commit;

        commit_if.rb_data <= rb_value;
        //BRANCH
        commit_if.branch_result <= execute_if.next_PC + (execute_if.offset_data<<2);
        //ALU
        if (execute_if.execute.alu_op == `ISA_ADD_OP) begin
            commit_if.alu_result <= ra_value + rb_value;
        end else if (execute_if.execute.alu_op == `ISA_SUB_OP) begin
            commit_if.alu_result <= ra_value + rb_value;            
        end
        if (commit_if.alu_result==0) begin
            commit_if.zero<='b1;
        end
    end
end
endmodule
