`include "CPU_define.vh"
`include "core/interfaces/CPU_fetch_if.sv"
`include "core/interfaces/CPU_decode_if.sv"
`include "core/interfaces/CPU_execute_if.sv"
`include "bank_reg/CPU_bank_reg_if.sv"
`include "forward_unit/CPU_FWUnit_if.sv"
`include "hazard_det_unit/CPU_HDUnit_if.sv"


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
    CPU_fetch_if.decode_req fetch_if,
    CPU_execute_if.master execute_if,
    output wire offload
);

//mem->wb

assign bank_reg_if.read_reg_a = decode_if.instr.r_instr.src1;
assign bank_reg_if.read_reg_b = ( decode_if.instr[31:25] == `ISA_STW_OP || decode_if.instr[31:25] == `ISA_STB_OP) ? decode_if.instr.r_instr.dst : decode_if.instr.r_instr.src2;

//HAZARD READ AFTER LOAD
assign HDUnit_if.decode_ra = decode_if.instr.r_instr.src1;
assign HDUnit_if.ra_use = (decode_if.instr[31:29] == `R_TYPE_OP || (decode_if.instr[31:29] == `M_TYPE_OP && decode_if.instr[31:25]!=`ISA_LDI_OP && decode_if.instr[31:25] != `ISA_MOV_OP) || decode_if.instr[31:25] == `ISA_BEQ_OP || decode_if.instr[31:25] == `ISA_JUMP_OP || decode_if.instr[31:25] == `ISA_TLB_WRITE_OP);

assign HDUnit_if.rb_use = (decode_if.instr[31:29] == `R_TYPE_OP || decode_if.instr[31:25] == `ISA_BEQ_OP || decode_if.instr[31:25] == `ISA_TLB_WRITE_OP);
assign HDUnit_if.decode_rb = decode_if.instr.r_instr.src2;


assign HDUnit_if.decode_rd = decode_if.instr.r_instr.dst;
assign HDUnit_if.rd_use = ((decode_if.instr[31:29] == `R_TYPE_OP && decode_if.instr[31:29] != `ISA_MUL_OP) || decode_if.instr[31:25] == `ISA_LDB_OP || decode_if.instr[31:25] == `ISA_LDW_OP);

wire [`REG_WIDTH-1:0] ra_value_br;
wire [`REG_WIDTH-1:0] rb_value_br;

//FW UNIT FOR BRANCHING
assign FWUnit_if.ra_decode_id = decode_if.instr.b_instr.src1;
assign FWUnit_if.rb_decode_id = decode_if.instr.b_instr.src2_offset_m;

assign ra_value_br = FWUnit_if.ra_decode_bypass_mul ? FWUnit_if.wb_value_mul : (FWUnit_if.ra_decode_bypass[1] ? FWUnit_if.commit_value : (FWUnit_if.ra_decode_bypass[0] ? FWUnit_if.wb_value : bank_reg_if.read_data_a));
assign rb_value_br = FWUnit_if.rb_decode_bypass_mul ? FWUnit_if.wb_value_mul : (FWUnit_if.rb_decode_bypass[1] ? FWUnit_if.commit_value : (FWUnit_if.rb_decode_bypass[0] ? FWUnit_if.wb_value : bank_reg_if.read_data_b));

//HAZARD BRANCHING
assign HDUnit_if.branch_decode= decode_if.instr.b_instr.opcode== `ISA_BEQ_OP;
assign HDUnit_if.jump_decode= decode_if.instr.b_instr.opcode== `ISA_JUMP_OP;

// CALCULATE OFFSETS
wire [`VIRTUAL_ADDR_WIDTH-1:0] branch_offset;
wire [`VIRTUAL_ADDR_WIDTH-1:0] jump_offset;

assign branch_offset = {{17{decode_if.instr.b_instr.offset_high[4]}}, decode_if.instr.b_instr.offset_high, decode_if.instr.b_instr.offset_low} << 2;
assign jump_offset = {{12{decode_if.instr.b_instr.offset_high[4]}}, decode_if.instr.b_instr.offset_high, decode_if.instr.b_instr.src2_offset_m, decode_if.instr.b_instr.offset_low};


//CHECK IF CHANGING


always_latch begin
    if (decode_if.valid_instr) begin
        if (decode_if.instr.b_instr.opcode == `ISA_JUMP_OP) begin
            fetch_if.jump = 1;
            fetch_if.jump_pc = ra_value_br + jump_offset;
        end else if(decode_if.instr.b_instr.opcode == `ISA_BEQ_OP && ra_value_br == rb_value_br) begin
            fetch_if.jump = 1;
            fetch_if.jump_pc = decode_if.next_PC + branch_offset;
        end else if (decode_if.instr.b_instr.opcode == `ISA_IRET_OP) begin
            fetch_if.jump = 1;
            fetch_if.jump_pc = decode_if.rm0;
        end else begin
            fetch_if.jump = 0;
        end
    end else begin
        fetch_if.jump = 0;
    end
end

//HAZARD BRANCHING
assign HDUnit_if.stall_decode = decode_if.tlb_exception.raise;

always @(posedge clock) begin
    if (reset) begin 
        execute_if.commit <= '0;
        execute_if.writeback.reg_write <= '0;
        offload <= 0;
    end else if (~HDUnit_if.E_stall) begin
        //PASS VALUES

        execute_if.ra_data <= (decode_if.instr[31:25] == `ISA_LDI_OP) ? 0 : (decode_if.instr[31:25] == `ISA_MOV_OP) ? decode_if.rm1 : ra_value_br;
        execute_if.rb_data <= rb_value_br;

        execute_if.ra_id <= decode_if.instr.r_instr.src1;
        execute_if.rb_id <= decode_if.instr.r_instr.src2;

        // execute_if.rm4 <= decode_if.rm4;

        execute_if.reg_dest <= decode_if.instr.r_instr.dst;
        if (HDUnit_if.E_nop || decode_if.nop || ~decode_if.valid_instr) begin
            execute_if.commit <= '0;
            execute_if.writeback <= '0;
            execute_if.execute.alu_op <= `ALU_ADD_OP;
        end else if (decode_if.tlb_exception.raise) begin
            // fetch_if.jump_PC <= `EXCEPTION_ADDR;
            // fetch_if.jump <= 1;
            decode_if.rm0 <= decode_if.tlb_exception.pc;
            decode_if.rm1 <= decode_if.tlb_exception.vaddr;
            decode_if.rm4 <= 1;
            
            execute_if.commit <= '0;
            execute_if.writeback <= '0;
            // TODO PUT ALL CONTROL TO 0
        //R_TYPE
        end else if (decode_if.instr[31:29] == `R_TYPE_OP) begin
            decode_if.itlb_write <= 0;
            decode_if.tlb_write.enable<=0;
            execute_if.execute.alu_op <= decode_if.instr[26:25];
            execute_if.execute.use_reg_b <= '1;
            execute_if.commit <= '0;
            if (decode_if.instr.r_instr.opcode== `ISA_MUL_OP) begin
                execute_if.writeback<=0;
            end else begin 
                //execute_if.writeback.mem_to_reg <= '0;
                execute_if.writeback.reg_write <= '1;
            end
        //M_TYPE
        end else if (decode_if.instr[31:29]==`M_TYPE_OP) begin
            execute_if.execute.use_reg_b <= '0;
            execute_if.execute.alu_op <= `ALU_ADD_OP;
            decode_if.itlb_write <= 0;
            decode_if.tlb_write.enable<=0;
            //LOAD
            if (decode_if.instr.m_instr.opcode== `ISA_LDB_OP || decode_if.instr.m_instr.opcode== `ISA_LDW_OP) begin
                execute_if.commit.mem_read <= '1;
                execute_if.commit.mem_write <= '0;
                // execute_if.writeback.mem_to_reg <= '1;
                execute_if.writeback.reg_write <= '1;
                execute_if.offset_data <= {{17{decode_if.instr.m_instr.offset[14]}}, decode_if.instr.m_instr.offset};
            //STORE
            end else if (decode_if.instr.m_instr.opcode== `ISA_STB_OP || decode_if.instr.m_instr.opcode== `ISA_STW_OP) begin
                execute_if.commit.mem_write <= '1;
                execute_if.commit.mem_read <= '0;
                execute_if.writeback.reg_write <= '0;
                execute_if.offset_data <= {{17{decode_if.instr.m_instr.offset[14]}}, decode_if.instr.m_instr.offset};
            end else if (decode_if.instr.m_instr.opcode== `ISA_LDI_OP) begin
                execute_if.commit <= '0;
                execute_if.offset_data <= { {12{1'(decode_if.instr.m_instr[19])}}, decode_if.instr.m_instr[19:0]};
                execute_if.writeback.reg_write <= '1;
            end else if (decode_if.instr.m_instr.opcode== `ISA_MOV_OP) begin
                execute_if.offset_data <= 0;
                execute_if.commit.mem_read <= '0;
                execute_if.commit.mem_write <= '0;
                //execute_if.writeback.mem_to_reg <= '0;
                execute_if.writeback.reg_write <= '1;
            end else begin
                $error("No mode implemented in decode: %h", decode_if.instr);
            end
            if (decode_if.instr.m_instr.opcode == `ISA_STW_OP || decode_if.instr.m_instr.opcode== `ISA_LDW_OP) begin
                execute_if.commit.mode <= WORD;
            end else if (decode_if.instr.m_instr.opcode == `ISA_STB_OP || decode_if.instr.m_instr.opcode== `ISA_LDB_OP) begin
                execute_if.commit.mode <= BYTE;
            end 
        //BTYPE
        end else if (decode_if.instr[31:29]==`B_TYPE_OP) begin
            if (decode_if.instr.b_instr.opcode == `ISA_IRET_OP)begin
                decode_if.rm4 <= 0;
                decode_if.itlb_write <= 0;
                decode_if.tlb_write.enable<=0;
            end else if (decode_if.instr.b_instr.opcode == `ISA_JUMP_OP || decode_if.instr.b_instr.opcode == `ISA_BEQ_OP) begin

            end else if (decode_if.instr.b_instr.opcode == `ISA_TLB_WRITE_OP) begin
                    decode_if.tlb_write.addr <= ra_value_br;
                    decode_if.tlb_write.data <= rb_value_br[`PHYSICAL_ADDR_WIDTH-1:0];
                if (decode_if.instr.b_instr.offset_low == `OFFSET_LOW_ITLB_WRITE) begin
                    decode_if.itlb_write <= 1;
                end else if (decode_if.instr.b_instr.offset_low == `OFFSET_LOW_DTLB_WRITE) begin
                    decode_if.tlb_write.enable<=1;
                end          
            end else if (decode_if.instr[31:25] == `ISA_STOP_OP) begin
                offload <= 1;
            end else begin
                $error("No mode implemented in decode: %h, opcode=%h", decode_if.instr, decode_if.instr.r_instr.opcode);
            end
            execute_if.commit <= '0;
            execute_if.writeback <= '0;
        end
        if (decode_if.instr.b_instr.opcode == `ISA_LDI_OP) begin
            execute_if.imm <= 1;
        end else begin
            execute_if.imm <= 0;
        end

    end

end
endmodule
