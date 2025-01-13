`include "CPU_define.vh"

module CPU_HDUnit
(
    CPU_HDUnit_if.slave HDUnit_if
);

wire read_load_hazard = HDUnit_if.execute_mem_read && ((HDUnit_if.ra_use && (HDUnit_if.decode_ra == HDUnit_if.execute_rd)) || (HDUnit_if.rb_use && (HDUnit_if.decode_rb == HDUnit_if.execute_rd)));
wire br_hazard_alu = HDUnit_if.branch_decode && (HDUnit_if.execute_rd == HDUnit_if.decode_ra || HDUnit_if.execute_rd == HDUnit_if.decode_rb) && HDUnit_if.execute_wb;
wire jump_hazard_alu = HDUnit_if.jump_decode && HDUnit_if.execute_rd == HDUnit_if.decode_ra && HDUnit_if.execute_wb;

wire br_hazard_load = HDUnit_if.branch_decode && HDUnit_if.commit_mem_read && (HDUnit_if.commit_rd == HDUnit_if.decode_ra || HDUnit_if.commit_rd == HDUnit_if.decode_rb);
wire jump_hazard_load = HDUnit_if.jump_decode && HDUnit_if.commit_mem_read && HDUnit_if.commit_rd == HDUnit_if.decode_ra;

wire mul_raw_hazard_0 = HDUnit_if.ra_use && HDUnit_if.mul_wb[0].write_back && ((HDUnit_if.mul_wb[0].rd_id == HDUnit_if.decode_ra) || (HDUnit_if.mul_wb[0].rd_id == HDUnit_if.decode_rb));
wire mul_raw_hazard_1 = HDUnit_if.ra_use && HDUnit_if.mul_wb[1].write_back && ((HDUnit_if.mul_wb[1].rd_id == HDUnit_if.decode_ra) || (HDUnit_if.mul_wb[0].rd_id == HDUnit_if.decode_rb));
wire mul_raw_hazard_2 = HDUnit_if.ra_use && HDUnit_if.mul_wb[2].write_back && ((HDUnit_if.mul_wb[2].rd_id == HDUnit_if.decode_ra) || (HDUnit_if.mul_wb[0].rd_id == HDUnit_if.decode_rb));
wire mul_raw_hazard_3 = HDUnit_if.ra_use && HDUnit_if.mul_wb[3].write_back && ((HDUnit_if.mul_wb[3].rd_id == HDUnit_if.decode_ra) || (HDUnit_if.mul_wb[0].rd_id == HDUnit_if.decode_rb));
wire mul_raw_hazard_4 = HDUnit_if.ra_use && HDUnit_if.mul_wb[4].write_back && ((HDUnit_if.mul_wb[4].rd_id == HDUnit_if.decode_ra) || (HDUnit_if.mul_wb[0].rd_id == HDUnit_if.decode_rb));

wire mul_raw_hazard = mul_raw_hazard_0 || mul_raw_hazard_1 || mul_raw_hazard_2 || mul_raw_hazard_3 || mul_raw_hazard_4;

wire mul_waw_hazard_0 = HDUnit_if.rd_use && HDUnit_if.mul_wb[0].write_back && (HDUnit_if.mul_wb[0].rd_id == HDUnit_if.decode_rd);
wire mul_waw_hazard_1 = HDUnit_if.rd_use && HDUnit_if.mul_wb[1].write_back && (HDUnit_if.mul_wb[1].rd_id == HDUnit_if.decode_rd);
wire mul_waw_hazard_2 = HDUnit_if.rd_use && HDUnit_if.mul_wb[2].write_back && (HDUnit_if.mul_wb[2].rd_id == HDUnit_if.decode_rd);
wire mul_waw_hazard_3 = HDUnit_if.rd_use && HDUnit_if.mul_wb[3].write_back && (HDUnit_if.mul_wb[3].rd_id == HDUnit_if.decode_rd);
wire mul_waw_hazard_4 = HDUnit_if.rd_use && HDUnit_if.mul_wb[4].write_back && (HDUnit_if.mul_wb[4].rd_id == HDUnit_if.decode_rd);

wire mul_waw_hazard = mul_waw_hazard_0 || mul_waw_hazard_1 || mul_waw_hazard_2 || mul_waw_hazard_3 || mul_waw_hazard_4;

assign HDUnit_if.stall = read_load_hazard || br_hazard_alu || jump_hazard_alu || br_hazard_load || jump_hazard_load || mul_raw_hazard || mul_waw_hazard;

endmodule
