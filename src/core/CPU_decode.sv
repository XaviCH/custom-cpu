`include "CPU_define.vh"

module CPU_decode
(
    input wire clock,
    input wire reset,
    
    CPU_bank_reg_if.master_read bank_reg_if,
    CPU_HDUnit_if.master_decode HDUnit_if,
    // input
    CPU_decode_if.slave decode_if,
    // ouput
    CPU_execute_if.master execute_if
);
//mem->wb

assign bank_reg_if.read_reg_a = decode_if.instr.r_instr.src1;
assign bank_reg_if.read_reg_b = decode_if.instr.r_instr.src2;

//HAZARD READ AFTER LOAD
assign HDUnit_if.ra_use = (decode_if.instr[31:29] == `R_TYPE_OP || (decode_if.instr[31:29] == `M_TYPE_OP && decode_if.instr[31:25] != `ISA_MOV_OP) || decode_if.instr[31:25] == `ISA_BEQ_OP || decode_if.instr[31:25] == `ISA_JUMP_OP || decode_if.instr[31:25] == `ISA_TLB_WRITE_OP);
assign HDUnit_if.decode_ra = decode_if.instr.r_instr.src1;
assign HDUnit_if.rb_use = (decode_if.instr[31:29] == `R_TYPE_OP || decode_if.instr[31:25] == `ISA_BEQ_OP || decode_if.instr[31:25] == `ISA_TLB_WRITE_OP);
assign HDUnit_if.decode_rb = decode_if.instr.r_instr.src2;

//HAZARD BRANCHING

always @(posedge clock, posedge reset) begin
    if (reset) begin 
        execute_if.commit <= '0;
        execute_if.writeback.reg_write <= '0;
    end else begin
        //PASS VALUES
        execute_if.next_PC <= decode_if.next_PC;

        execute_if.ra_data <= bank_reg_if.read_data_a;
        execute_if.rb_data <= bank_reg_if.read_data_b;

        execute_if.ra_id <= decode_if.instr.r_instr.src1;
        execute_if.rb_id <= decode_if.instr.r_instr.src2;

        execute_if.reg_dest <= decode_if.instr.r_instr.dst;
        if (HDUnit_if.stall) begin
            execute_if.commit <= '0;
            execute_if.writeback.reg_write <= '0;
        //R_TYPE
        end else if (decode_if.instr[31:29] == `R_TYPE_OP) begin
            execute_if.execute.use_reg_b <= '1;
            execute_if.commit <= '0;
            execute_if.writeback.mem_to_reg <= '0;
            execute_if.writeback.reg_write <= '1;
            if (decode_if.instr.r_instr.opcode== `ISA_MUL_OP) begin
                //TODO: MUL
            end else begin 
                execute_if.execute.alu_op <= decode_if.instr[26:25];
            end
        //M_TYPE
        end else if (decode_if.instr[31:29]==`M_TYPE_OP) begin
            execute_if.execute.use_reg_b <= '0;
            execute_if.execute.alu_op <= `ALU_ADD_OP;
            execute_if.commit.branch <= '0;
            execute_if.commit.jump <= '0;
            execute_if.offset_data <= {{17{decode_if.instr.m_instr.offset[14]}}, decode_if.instr.m_instr.offset};
            //LOAD
            if (decode_if.instr.b_instr.opcode== `ISA_LDB_OP || decode_if.instr.b_instr.opcode== `ISA_LDW_OP) begin
                execute_if.commit.mem_read <= '1;
                execute_if.commit.mem_write <= '0;
                execute_if.writeback.mem_to_reg <= '1;
                execute_if.writeback.reg_write <= '1;
            //STORE
            end else if (decode_if.instr.b_instr.opcode== `ISA_STB_OP || decode_if.instr.b_instr.opcode== `ISA_STW_OP) begin 
                execute_if.commit.mem_write <= '1;
                execute_if.commit.mem_read <= '0;
                execute_if.writeback.reg_write <= '0;
            end
        //BTYPE
        end else if (decode_if.instr[31:29]==`B_TYPE_OP) begin
            execute_if.commit.mem_read <= '0;
            execute_if.commit.mem_write <= '0;
            execute_if.writeback <= '0;
            if (decode_if.instr.b_instr.opcode== `ISA_BEQ_OP) begin
                execute_if.execute.alu_op <= `ALU_SUB_OP;
            execute_if.execute.use_reg_b <= '1;
                execute_if.offset_data <= {{17{decode_if.instr.b_instr.offset_high[4]}}, decode_if.instr.b_instr.offset_high, decode_if.instr.b_instr.offset_low};
                execute_if.commit.branch <= 1;
                execute_if.commit.jump <= 0;
            end else  if (decode_if.instr.b_instr.opcode== `ISA_JUMP_OP) begin
                execute_if.execute.alu_op <= `ALU_ADD_OP;
            execute_if.execute.use_reg_b <= '0;
                execute_if.offset_data <= {{12{decode_if.instr.b_instr.offset_high[4]}}, decode_if.instr.b_instr.offset_high, decode_if.instr.b_instr.src2_offset_m, decode_if.instr.b_instr.offset_low};
                execute_if.commit.branch <= 1;
                execute_if.commit.jump <= 1;
            end
        end
        // TODO Make others
    end

end
endmodule
