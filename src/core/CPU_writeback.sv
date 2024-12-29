module CPU_writeback
(
    input wire clock;
    input wire reset;

    // input
    CPU_writeback_if.slave writeback_if,
    CPU_bank_reg_if.master bank_reg_if,
    // CPU_FWUnit_input_if.master FWUnit_input_if,
    // output
    output wire reg_write,
    output wire [$clog2(NUM_REGS)] write_register,
    output wire [REG_WIDTH] write_data
);
// assign FWUnit_input_if.write_back_wb <= writeback_if.writeback;

always @(posedge clock, posedge reset) begin
    if (reset) begin 
        bank_reg_if.writeback.write_enable <= '0;
    end else begin
        if (writeback_if.write_back.reg_write) begin
            bank_reg_if.writeback.write_enable <= '1;
            bank_reg_if.write_data <= (bank_reg_if.writeback.alu_mem ? bank_reg_if.writeback.mem_data : bank_reg_if.writeback.alu_data);
            bank_reg_if.writeback.write_reg <= writeback_if.write_back.reg_dest;
        end else begin 
            bank_reg_if.writeback.write_enable <= '0;
        end
    end
end

endmodule