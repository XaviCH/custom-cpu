`include "CPU_define.vh"
`include "bank_reg/CPU_bank_reg_if.sv"
`include "hazard_det_unit/CPU_HDUnit_if.sv"

module CPU_mul_unit
(
    input wire clock,
    input wire reset,
    
    CPU_bank_reg_if.master_write bank_reg,
    CPU_HDUnit_if.master_mul HDUnit_if,
    CPU_mul_unit_if.slave mul_unit_if
);

assign mul_unit_if.mul_stages[0].writeback_mul = mul_unit_if.writeback_mul;
assign mul_unit_if.mul_stages[0].rd_id = mul_unit_if.rd_id;
assign mul_unit_if.mul_stages[0].mul_result= mul_unit_if.ra_data * mul_unit_if.rb_data;

assign HDUnit_if.mul_wb[0].write_back=mul_unit_if.mul_stages[0].writeback_mul;
assign HDUnit_if.mul_wb[0].rd_id=mul_unit_if.mul_stages[0].rd_id;

assign HDUnit_if.mul_wb[1].write_back=mul_unit_if.mul_stages[1].writeback_mul;
assign HDUnit_if.mul_wb[1].rd_id=mul_unit_if.mul_stages[1].rd_id;

assign HDUnit_if.mul_wb[2].write_back=mul_unit_if.mul_stages[2].writeback_mul;
assign HDUnit_if.mul_wb[2].rd_id=mul_unit_if.mul_stages[2].rd_id;

assign HDUnit_if.mul_wb[3].write_back=mul_unit_if.mul_stages[3].writeback_mul;
assign HDUnit_if.mul_wb[3].rd_id=mul_unit_if.mul_stages[3].rd_id;

assign HDUnit_if.mul_wb[4].write_back=mul_unit_if.mul_stages[4].writeback_mul;
assign HDUnit_if.mul_wb[4].rd_id=mul_unit_if.mul_stages[4].rd_id;

integer i;

always @(posedge clock, posedge reset) begin
    if (reset) begin 
        for (i=0; i<`MUL_STAGES; i=i+1) mul_unit_if.mul_stages[i] <= 0;
    end else begin
        bank_reg.writeback_mul <= mul_unit_if.mul_stages[4];
        mul_unit_if.mul_stages[4]<=mul_unit_if.mul_stages[3];
        mul_unit_if.mul_stages[3]<=mul_unit_if.mul_stages[2];
        mul_unit_if.mul_stages[2]<=mul_unit_if.mul_stages[1];
        mul_unit_if.mul_stages[1]<=mul_unit_if.mul_stages[0];
    end
end

endmodule