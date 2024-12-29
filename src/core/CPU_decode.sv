`include "CPU_define.vh"

module CPU_decode
(
    input wire clock,
    input wire reset,
    
    CPU_bank_reg_if.master bank_reg_request_if,
    // input
    CPU_decode_if.slave decode_if,
    // ouput
    CPU_execute_if.master execute_if
);

assign bank_reg_request_if.read_reg_a = decode_if.instr[19:15];
assign bank_reg_request_if.read_reg_b = decode_if.instr[14:10];
assign execute_if.next_PC = decode_if.next_PC;

assign execute_if.ra_data = bank_reg_request_if.read_data_a;
assign execute_if.rb_data = bank_reg_request_if.read_data_b;

assign execute_if.offset_data = {{17{decode_if.instr[14]}}, decode_if.instr[14:0]};
assign execute_if.reg_dest = decode_if.instr[24:20];

always @(posedge clock) begin
    if (reset) begin 
        execute_if.commit <= '0;
        execute_if.writeback.reg_write <= '0;
    end else begin
        if (decode_if.instr[31:29] == `R_TYPE_OP) begin
            execute_if.reg_b <= '1;
            execute_if.commit <= '0;
            execute_if.writeback.mem_to_reg <= '0;
            execute_if.writeback.reg_write <= '1;
            execute_if.writeback.mem_to_reg <= '0;
            if (decode_if.instr[31:25]== `ISA_ADD_OP) begin
                //ADD
                execute_if.execute.alu_op <= `ALU_ADD_OP;
            end else if (decode_if.instr[31:25]== `ISA_SUB_OP) begin
                //SUB
                execute_if.execute.alu_op <= `ALU_SUB_OP;
            end else begin 
                //MUL
            end
        end else if (decode_if.instr[31:29]==`M_TYPE_OP) begin
            execute_if.reg_b <= '0;
            execute_if.execute.alu_op <= `ALU_ADD_OP;
            execute_if.commit <= '1;
            execute_if.writeback.mem_to_reg <= '1;
            execute_if.writeback.reg_write <= '1;
        
        end else if (decode_if.instr[31:29]==`B_TYPE_OP) begin
        end
        // TODO Make others
    end

end
endmodule
