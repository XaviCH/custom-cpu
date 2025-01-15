`include "CPU_define.vh"

module CPU_bank_reg
(
    input wire clock,
    input wire reset,
    
    CPU_bank_reg_if.slave bank_reg_if,
    CPU_FWUnit_if.master_writeback FWUnit_if
);

integer i;
reg [`REG_WIDTH-1:0] reg_file [`NUM_REGS];

assign bank_reg_if.read_data_a = reg_file[bank_reg_if.read_reg_a];
assign bank_reg_if.read_data_b = reg_file[bank_reg_if.read_reg_b];

assign FWUnit_if.writeback_wb_mul = bank_reg_if.writeback_mul.write_enable_mul;
assign FWUnit_if.rd_wb_mul = bank_reg_if.writeback_mul.write_reg_mul;
assign FWUnit_if.wb_value_mul = bank_reg_if.writeback_mul.write_data_mul;

always @(posedge clock) begin
    if (reset) begin 
        for (i=0; i<`NUM_REGS; i=i+1) reg_file[i] <= 0;
    end else begin
        $display("--- BANK REG ---");
        $display("reg 0: %d", reg_file[0]);
        $display("reg 1: %d", reg_file[1]);
        $display("reg 2: %d", reg_file[2]);
        $display("reg 3: %d", reg_file[3]);
        $display("reg 4: %d", reg_file[4]);
        // $display("reg 7: %h", reg_file[7]);
            
        if (bank_reg_if.writeback.write_enable) reg_file[bank_reg_if.writeback.write_reg] <= bank_reg_if.writeback.write_data;
        if (bank_reg_if.writeback_mul.write_enable_mul) reg_file[bank_reg_if.writeback_mul.write_reg_mul] <= bank_reg_if.writeback_mul.write_data_mul;
    end
end

endmodule
