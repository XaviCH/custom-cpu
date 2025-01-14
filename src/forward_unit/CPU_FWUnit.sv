`include "CPU_define.vh"

module CPU_FWUnit
(
    CPU_FWUnit_if.slave FWUnit_if
);

assign FWUnit_if.ra_execute_bypass[1] = FWUnit_if.ra_execute_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit;
assign FWUnit_if.ra_execute_bypass[0] = !(FWUnit_if.ra_execute_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit) && FWUnit_if.ra_execute_id == FWUnit_if.rd_wb && FWUnit_if.writeback_wb;

assign FWUnit_if.rb_execute_bypass[1] = FWUnit_if.rb_execute_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit;
assign FWUnit_if.rb_execute_bypass[0] = !(FWUnit_if.rb_execute_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit) && FWUnit_if.rb_execute_id == FWUnit_if.rd_wb && FWUnit_if.writeback_wb;

assign FWUnit_if.ra_decode_bypass[1] = FWUnit_if.ra_decode_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit;
assign FWUnit_if.ra_decode_bypass[0] = !(FWUnit_if.ra_decode_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit) && FWUnit_if.ra_decode_id == FWUnit_if.rd_wb && FWUnit_if.writeback_wb;

assign FWUnit_if.rb_decode_bypass[1] = FWUnit_if.rb_decode_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit;
assign FWUnit_if.rb_decode_bypass[0] = !(FWUnit_if.rb_decode_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit) && FWUnit_if.rb_decode_id == FWUnit_if.rd_wb && FWUnit_if.writeback_wb;

assign FWUnit_if.cache_data_bypass =  (FWUnit_if.rd_commit == FWUnit_if.rd_wb && FWUnit_if.writeback_wb);

assign FWUnit_if.ra_decode_bypass_mul = FWUnit_if.writeback_wb_mul && FWUnit_if.ra_decode_id == FWUnit_if.rd_wb_mul; 
assign FWUnit_if.rb_decode_bypass_mul = FWUnit_if.writeback_wb_mul && FWUnit_if.rb_decode_id == FWUnit_if.rd_wb_mul;

assign FWUnit_if.ra_execute_bypass_mul = FWUnit_if.writeback_wb_mul && FWUnit_if.ra_execute_id == FWUnit_if.rd_wb_mul;
assign FWUnit_if.rb_execute_bypass_mul = FWUnit_if.writeback_wb_mul && FWUnit_if.rb_execute_id == FWUnit_if.rd_wb_mul;


// CASES
// W_data -> commit_if.cache_data_in ([LD, ADD] -> ST)
// W_data -> op1_execute_bypass, op2_execute_bypass, rb_execute
// W_data -> decode_ra, decode_rb 

// C_addr -> op1_execute_bypass, op2_execute_bypass, rb_execute
// C_addr -> decode_ra, decode_rb 

endmodule
