`include "CPU_define.vh"

module CPU_HDUnit
(
    CPU_HDUnit_if.slave HDUnit_if
);

wire read_load_hazard, br_hazard_alu, jump_hazard_alu, 
    br_hazard_load, jump_hazard_load, 
    mul_raw_hazard, mul_waw_hazard,
    mul_raw_hazard_0, mul_raw_hazard_1, mul_raw_hazard_2, mul_raw_hazard_3, mul_raw_hazard_4,
    mul_waw_hazard_0, mul_waw_hazard_1, mul_waw_hazard_2, mul_waw_hazard_3, mul_waw_hazard_4;

assign read_load_hazard = 
    HDUnit_if.execute_mem_read &&
    (
        (HDUnit_if.ra_use && (HDUnit_if.decode_ra == HDUnit_if.execute_rd)) || 
        (HDUnit_if.rb_use && (HDUnit_if.decode_rb == HDUnit_if.execute_rd))
    );

assign br_hazard_alu = HDUnit_if.branch_decode && (HDUnit_if.execute_rd == HDUnit_if.decode_ra || HDUnit_if.execute_rd == HDUnit_if.decode_rb) && HDUnit_if.execute_wb;
assign jump_hazard_alu = HDUnit_if.jump_decode && HDUnit_if.execute_rd == HDUnit_if.decode_ra && HDUnit_if.execute_wb;

assign br_hazard_load = HDUnit_if.branch_decode && HDUnit_if.commit_mem_read && (HDUnit_if.commit_rd == HDUnit_if.decode_ra || HDUnit_if.commit_rd == HDUnit_if.decode_rb);
assign jump_hazard_load = HDUnit_if.jump_decode && HDUnit_if.commit_mem_read && HDUnit_if.commit_rd == HDUnit_if.decode_ra;

assign mul_raw_hazard_0 = HDUnit_if.ra_use && HDUnit_if.mul_wb[0].write_back && ((HDUnit_if.mul_wb[0].rd_id == HDUnit_if.decode_ra) || (HDUnit_if.mul_wb[0].rd_id == HDUnit_if.decode_rb));
assign mul_raw_hazard_1 = HDUnit_if.ra_use && HDUnit_if.mul_wb[1].write_back && ((HDUnit_if.mul_wb[1].rd_id == HDUnit_if.decode_ra) || (HDUnit_if.mul_wb[1].rd_id == HDUnit_if.decode_rb));
assign mul_raw_hazard_2 = HDUnit_if.ra_use && HDUnit_if.mul_wb[2].write_back && ((HDUnit_if.mul_wb[2].rd_id == HDUnit_if.decode_ra) || (HDUnit_if.mul_wb[2].rd_id == HDUnit_if.decode_rb));
assign mul_raw_hazard_3 = HDUnit_if.ra_use && HDUnit_if.mul_wb[3].write_back && ((HDUnit_if.mul_wb[3].rd_id == HDUnit_if.decode_ra) || (HDUnit_if.mul_wb[3].rd_id == HDUnit_if.decode_rb));
assign mul_raw_hazard_4 = HDUnit_if.ra_use && HDUnit_if.mul_wb[4].write_back && ((HDUnit_if.mul_wb[4].rd_id == HDUnit_if.decode_ra) || (HDUnit_if.mul_wb[4].rd_id == HDUnit_if.decode_rb));

assign mul_raw_hazard = mul_raw_hazard_0 || mul_raw_hazard_1 || mul_raw_hazard_2 || mul_raw_hazard_3 || mul_raw_hazard_4;

assign mul_waw_hazard_0 = HDUnit_if.rd_use && HDUnit_if.mul_wb[0].write_back && (HDUnit_if.mul_wb[0].rd_id == HDUnit_if.decode_rd);
assign mul_waw_hazard_1 = HDUnit_if.rd_use && HDUnit_if.mul_wb[1].write_back && (HDUnit_if.mul_wb[1].rd_id == HDUnit_if.decode_rd);
assign mul_waw_hazard_2 = HDUnit_if.rd_use && HDUnit_if.mul_wb[2].write_back && (HDUnit_if.mul_wb[2].rd_id == HDUnit_if.decode_rd);
assign mul_waw_hazard_3 = HDUnit_if.rd_use && HDUnit_if.mul_wb[3].write_back && (HDUnit_if.mul_wb[3].rd_id == HDUnit_if.decode_rd);
assign mul_waw_hazard_4 = HDUnit_if.rd_use && HDUnit_if.mul_wb[4].write_back && (HDUnit_if.mul_wb[4].rd_id == HDUnit_if.decode_rd);

assign mul_waw_hazard = mul_waw_hazard_0 || mul_waw_hazard_1 || mul_waw_hazard_2 || mul_waw_hazard_3 || mul_waw_hazard_4;

assign HDUnit_if.stall =  br_hazard_load || jump_hazard_load || HDUnit_if.cache_miss;

logic F_stall, D_stall, E_stall;
logic E_nop;

assign F_stall = HDUnit_if.stall | mul_waw_hazard | mul_raw_hazard | read_load_hazard | br_hazard_alu | jump_hazard_alu;
assign D_stall = HDUnit_if.stall | mul_waw_hazard | mul_raw_hazard | read_load_hazard | br_hazard_alu | jump_hazard_alu;
assign E_nop = mul_waw_hazard | mul_raw_hazard | read_load_hazard | br_hazard_alu | jump_hazard_alu;
assign E_stall = HDUnit_if.stall;

assign HDUnit_if.E_stall = E_stall;
assign HDUnit_if.E_nop = E_nop;

endmodule

