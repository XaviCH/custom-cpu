`include "CPU_define.vh"

module CPU_decode
(
    input wire clock,
    input wire reset,
    
    CPU_bank_reg_if.master_read bank_reg_if,
    CPU_FWUnit_if.master_decode FWUnit_if,
    CPU_HDUnit_if.master_decode HDUnit_if,
    // input
    CPU_decode_if.slave decode_if,
    // ouput
    CPU_fetch_if.master fetch_if,
    CPU_mul_unit_if.master_decode mul_unit_if,
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

wire [`REG_WIDTH-1:0] ra_value_br;
wire [`REG_WIDTH-1:0] rb_value_br;

//FW UNIT FOR BRANCHING
assign FWUnit_if.ra_decode_id = decode_if.instr.b_instr.src1;
assign FWUnit_if.rb_decode_id = decode_if.instr.b_instr.src2_offset_m;

assign ra_value_br = (FWUnit_if.ra_decode_bypass[1] ? FWUnit_if.commit_value : (FWUnit_if.ra_decode_bypass[0] ? FWUnit_if.wb_value : bank_reg_if.read_data_a));
assign rb_value_br = (FWUnit_if.rb_decode_bypass[1] ? FWUnit_if.commit_value : (FWUnit_if.rb_decode_bypass[0] ? FWUnit_if.wb_value : bank_reg_if.read_data_b));

//HAZARD BRANCHING
assign HDUnit_if.branch_decode= decode_if.instr.b_instr.opcode== `ISA_BEQ_OP;
assign HDUnit_if.jump_decode= decode_if.instr.b_instr.opcode== `ISA_JUMP_OP;

// CALCULATE OFFSETS
wire [`VIRTUAL_ADDR_WIDTH-1:0] branch_offset;
wire [`VIRTUAL_ADDR_WIDTH-1:0] jump_offset;

assign branch_offset = {{17{decode_if.instr.b_instr.offset_high[4]}}, decode_if.instr.b_instr.offset_high, decode_if.instr.b_instr.offset_low} << 2;
assign jump_offset = {{12{decode_if.instr.b_instr.offset_high[4]}}, decode_if.instr.b_instr.offset_high, decode_if.instr.b_instr.src2_offset_m, decode_if.instr.b_instr.offset_low};

assign fetch_if.new_PC = decode_if.instr.b_instr.opcode== `ISA_BEQ_OP ? decode_if.next_PC + branch_offset : ra_value_br + jump_offset;

//CHECK IF CHANGING
assign fetch_if.change_PC = (decode_if.instr.b_instr.opcode== `ISA_BEQ_OP && ra_value_br == rb_value_br) || decode_if.instr.b_instr.opcode== `ISA_JUMP_OP;


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
        if (HDUnit_if.stall || decode_if.nop) begin
            execute_if.commit <= '0;
            execute_if.writeback <= '0;
            mul_unit_if.writeback_mul<=0;
        //R_TYPE
        end else if (decode_if.instr[31:29] == `R_TYPE_OP) begin
            execute_if.execute.use_reg_b <= '1;
            execute_if.commit <= '0;
            if (decode_if.instr.r_instr.opcode== `ISA_MUL_OP) begin
                mul_unit_if.writeback_mul<=1;
                execute_if.writeback<=0;
            end else begin 
                execute_if.writeback.mem_to_reg <= '0;
                execute_if.writeback.reg_write <= '1;
                execute_if.execute.alu_op <= decode_if.instr[26:25];
                mul_unit_if.writeback_mul<=0;
            end
        //M_TYPE
        end else if (decode_if.instr[31:29]==`M_TYPE_OP) begin
            execute_if.execute.use_reg_b <= '0;
            execute_if.execute.alu_op <= `ALU_ADD_OP;
            execute_if.offset_data <= {{17{decode_if.instr.m_instr.offset[14]}}, decode_if.instr.m_instr.offset};
            mul_unit_if.writeback_mul<=0;
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
            execute_if.commit <= '0;
            execute_if.writeback <= '0;
            mul_unit_if.writeback_mul<=0;
        end
        // TODO Make others
    end

end
endmodule
