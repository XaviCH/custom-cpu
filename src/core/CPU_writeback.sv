module CPU_writeback
(
    input wire clock,
    input wire reset,
    // input
    CPU_writeback_if.slave writeback_if,
    CPU_bank_reg_if.master_write bank_reg_if,
    CPU_FWUnit_if.master_writeback FWUnit_if
    // CPU_FWUnit_input_if.master FWUnit_input_if,
);
// assign FWUnit_input_if.write_back_wb <= writeback_if.writeback;

// assign bank_reg_if.write_enable = writeback_if.writeback.reg_write;
// assign bank_reg_if.write_data = (writeback_if.writeback.mem_to_reg ? writeback_if.mem_data : writeback_if.alu_data);
// assign bank_reg_if.write_reg = writeback_if.reg_dest;

// assign bank_reg_if.write_enable_mul = writeback_if.writeback_mul.writeback_mul;
// assign bank_reg_if.write_data_mul = writeback_if.writeback_mul.mul_result;
// assign bank_reg_if.write_reg_mul = writeback_if.writeback_mul.rd_id;

// assign FWUnit_if.rd_wb = writeback_if.reg_dest;
// assign FWUnit_if.writeback_wb = writeback_if.writeback.reg_write;
// assign FWUnit_if.wb_value = writeback_if.alu_data;

// assign FWUnit_if.rd_wb_mul = writeback_if.writeback_mul.rd_id;
// assign FWUnit_if.writeback_wb_mul = writeback_if.writeback_mul.writeback_mul;
// assign FWUnit_if.wb_value_mul = writeback_if.writeback_mul.mul_result;

endmodule