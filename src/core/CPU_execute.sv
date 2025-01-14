`include "CPU_define.vh"
`include "core/interfaces/CPU_commit_if.sv"
`include "core/interfaces/CPU_execute_if.sv"
`include "bank_reg/CPU_bank_reg_if.sv"
`include "forward_unit/CPU_FWUnit_if.sv"
`include "hazard_det_unit/CPU_HDUnit_if.sv"

module CPU_execute
(
    input wire clock,
    input wire reset,

    // input
    CPU_execute_if.slave execute_if,
    
    // output
    CPU_FWUnit_if.master_execute FWUnit_if,
    CPU_HDUnit_if.master_execute HDUnit_if,
    CPU_bank_reg_if.master_execute bank_reg_if,
    CPU_commit_if.master commit_if
);

wire [`REG_WIDTH-1:0] ra_value;
wire [`REG_WIDTH-1:0] rb_value;

wire [`REG_WIDTH-1:0] op1_value;
wire [`REG_WIDTH-1:0] op2_value;

typedef struct packed {
    logic writeback_mul;
    logic [$clog2(`NUM_REGS)-1:0] rd_id;
    logic [`REG_WIDTH-1:0] mul_result;
} writeback_mul_t;

writeback_mul_t mul_stages[`MUL_STAGES];

assign FWUnit_if.ra_execute_id = execute_if.ra_id;
assign FWUnit_if.rb_execute_id = ( execute_if.commit.mem_write ? execute_if.reg_dest : execute_if.rb_id);

assign ra_value = FWUnit_if.ra_execute_bypass_mul ? FWUnit_if.wb_value_mul : (FWUnit_if.ra_execute_bypass[1] ? FWUnit_if.commit_value : (FWUnit_if.ra_execute_bypass[0] ? FWUnit_if.wb_value : execute_if.ra_data));
assign rb_value = FWUnit_if.rb_execute_bypass_mul ? FWUnit_if.wb_value_mul : (FWUnit_if.rb_execute_bypass[1] ? FWUnit_if.commit_value : (FWUnit_if.rb_execute_bypass[0] ? FWUnit_if.wb_value : execute_if.rb_data));

assign op1_value =  (execute_if.imm ? 0 : ra_value);
assign op2_value =  (execute_if.execute.use_reg_b ? rb_value : execute_if.offset_data);

assign mul_stages[0].writeback_mul = (execute_if.execute.alu_op == `ALU_MUL_OP);
assign mul_stages[0].rd_id = execute_if.reg_dest;
assign mul_stages[0].mul_result= op1_value * op2_value;

assign HDUnit_if.mul_wb[0].write_back = mul_stages[0].writeback_mul;
assign HDUnit_if.mul_wb[0].rd_id = mul_stages[0].rd_id;

assign HDUnit_if.mul_wb[1].write_back = mul_stages[1].writeback_mul;
assign HDUnit_if.mul_wb[1].rd_id = mul_stages[1].rd_id;

assign HDUnit_if.mul_wb[2].write_back = mul_stages[2].writeback_mul;
assign HDUnit_if.mul_wb[2].rd_id = mul_stages[2].rd_id;

assign HDUnit_if.mul_wb[3].write_back = mul_stages[3].writeback_mul;
assign HDUnit_if.mul_wb[3].rd_id = mul_stages[3].rd_id;

assign HDUnit_if.mul_wb[4].write_back = mul_stages[4].writeback_mul;
assign HDUnit_if.mul_wb[4].rd_id = mul_stages[4].rd_id;

integer i;

assign commit_if.alu_result = execute_if.execute.alu_op == `ALU_ADD_OP ? op1_value + op2_value : op1_value - op2_value;
assign commit_if.rb_data = rb_value;

always @(posedge clock) begin
    if (reset) begin
        for (i=0; i<`MUL_STAGES; i=i+1) mul_stages[i] <= 0;
        //TODO: reset 
    end else begin
        //PASS VALUES
        // commit_if.reg_dest <= execute_if.reg_dest;
        // commit_if.writeback <= execute_if.writeback;
        commit_if.commit <= execute_if.commit;
        
        //ALU
        // if (execute_if.execute.alu_op == `ALU_ADD_OP) begin
        //     commit_if.alu_result <= ra_value + rb_value;
        // end else if (execute_if.execute.alu_op == `ALU_SUB_OP) begin
        //     commit_if.alu_result <= ra_value + rb_value;            
        // end 

        bank_reg_if.writeback_mul <= mul_stages[4];
        mul_stages[4]<=mul_stages[3];
        mul_stages[3]<=mul_stages[2];
        mul_stages[2]<=mul_stages[1];
        mul_stages[1]<=mul_stages[0];
    end
end
endmodule

