`include "CPU_define.vh"

module CPU_decode;
(
    input wire clock,
    input wire reset,
    
    CPU_bank_reg_if.master_read bank_reg_request_if,
    CPU_bank_reg_if.slave bank_reg_response_if,
    // input
    CPU_decode_if.slave decode_if,
    // ouput
    CPU_execute_if.master execute_if
);

assign bank_reg_request_if.read_reg_a = decode_if.instr[19:15];
assign bank_reg_request_if.read_reg_b = decode_if.instr[14:10];
assign execute_if.ra_data = bank_reg_response_if.read_data_a;
assign execute_if.rb_data = bank_reg_response_if.read_data_b;

always @(posedge clock) begin
    if (reset) begin 
        execute_if.commit <= '0;
        execute_if.writeback.reg_write <= '0;
    end else begin
        if (decode_if.instr[31:28] == ISA_ADD_OP) begin
            execute_if.execute.alu_op <= ALU_ADD_OP;
            execute_if.commit <= '0;
            execute_if.writeback.mem_to_reg <= '0;
            execute_if.writeback.reg_write <= '1;
        end else if (decode_if.instr[31:28] == ISA_SUB_OP) begin
            execute_if.ex.alu_op <= ALU_SUB_OP;
            execute_if.commit <= '0;
            execute_if.writeback.mem_to_reg <= '0;
            execute_if.writeback.reg_write <= '1;
        end else if (decode_if.instr[31:28] == ISA_MUL_OP) begin
            execute_if.ex.alu_op <= ALU_MUL_OP;
            execute_if.commit <= '0;
            execute_if.writeback.mem_to_reg <= '0;
            execute_if.writeback.reg_write <= '1;
        end
        // TODO Make others
    end

end

endmodule