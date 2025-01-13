`include "CPU_define.vh"

module CPU_bank_reg
(
    input wire clock,
    input wire reset,
    
    CPU_bank_reg_if.slave bank_reg_if
);

integer i;
reg [`REG_WIDTH-1:0] reg_file [`NUM_REGS];

assign bank_reg_if.read_data_a = reg_file[bank_reg_if.read_reg_a];
assign bank_reg_if.read_data_b = reg_file[bank_reg_if.read_reg_b];

always @(posedge clock) begin
    if (reset) begin 
        for (i=0; i<`NUM_REGS; i=i+1) reg_file[i] <= 0;
    end else begin
        if (bank_reg_if.write_enable) reg_file[bank_reg_if.write_reg] <= bank_reg_if.write_data;
        if (bank_reg_if.write_back_mul.write_enable_mul) reg_file[bank_reg_if.write_back_mul.write_reg_mul] <= bank_reg_if.write_back_mul.write_data_mul;
    end
end

endmodule
