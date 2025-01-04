`include "CPU_define.vh"

module CPU_HDUnit
(
    input wire clock,
    input wire reset,
    
    CPU_HDUnit_if.slave HDUnit_if
);

wire read_load_hazard = HDUnit_if.execute_mem_read && ((HDUnit_if.ra_use && (HDUnit_if.decode_ra == HDUnit_if.execute_rd)) || (HDUnit_if.rb_use && (HDUnit_if.decode_rb == HDUnit_if.execute_rd)));
wire br_hazard_alu = HDUnit_if.branch_decode && (HDUnit_if.execute_rd == HDUnit_if.decode_ra || HDUnit_if.execute_rd == HDUnit_if.decode_rb) && HDUnit_if.execute_wb;
wire jump_hazard_alu = HDUnit_if.jump_decode && HDUnit_if.execute_rd == HDUnit_if.decode_ra && HDUnit_if.execute_wb;

wire br_hazard_load = HDUnit_if.branch_decode && HDUnit_if.commit_mem_read && (HDUnit_if.commit_rd == HDUnit_if.decode_ra || HDUnit_if.commit_rd == HDUnit_if.decode_rb);
wire jump_hazard_load = HDUnit_if.jump_decode && HDUnit_if.commit_mem_read && HDUnit_if.commit_rd == HDUnit_if.decode_ra;

assign HDUnit_if.stall = read_load_hazard || br_hazard_alu || jump_hazard_alu || br_hazard_load || jump_hazard_load;

endmodule