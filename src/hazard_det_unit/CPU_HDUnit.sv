`include "CPU_define.vh"

module CPU_HDUnit
(
    input wire clock,
    input wire reset,
    
    CPU_HDUnit_if.slave HDUnit_if
);

assign HDUnit_if.stall = HDUnit_if.execute_mem_read && ((HDUnit_if.ra_use && (HDUnit_if.decode_ra == HDUnit_if.execute_rd)) || (HDUnit_if.rb_use && (HDUnit_if.decode_rb == HDUnit_if.execute_rd)));

endmodule