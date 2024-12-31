`include "CPU_define.vh"

module CPU_FWUnit
(
    input wire clock,
    input wire reset,
    
    CPU_FWUnit_if.slave FWUnit_if
);

assign FWUnit_if.ra_bypass[1] = FWUnit_if.ra_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit;
assign FWUnit_if.ra_bypass[0] = !(FWUnit_if.ra_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit) && FWUnit_if.ra_id == FWUnit_if.rd_wb && FWUnit_if.writeback_wb;

assign FWUnit_if.rb_bypass[1] = FWUnit_if.rb_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit;
assign FWUnit_if.rb_bypass[0] = !(FWUnit_if.rb_id == FWUnit_if.rd_commit && FWUnit_if.writeback_commit) && FWUnit_if.rb_id == FWUnit_if.rd_wb && FWUnit_if.writeback_wb;

endmodule