module CPU_writeback
(
    input wire clock,
    input wire reset,
    // input
    CPU_writeback_if.slave writeback_if,
    CPU_bank_reg_if.master_write bank_reg_if
    // CPU_FWUnit_input_if.master FWUnit_input_if,
);
// assign FWUnit_input_if.write_back_wb <= writeback_if.writeback;

assign bank_reg_if.write_enable = writeback_if.writeback.reg_write;
assign bank_reg_if.write_data = (writeback_if.writeback.mem_to_reg ? writeback_if.mem_data : writeback_if.alu_data);
assign bank_reg_if.write_reg = writeback_if.reg_dest;

endmodule