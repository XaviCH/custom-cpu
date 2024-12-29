`include "CPU_define.vh"

module CPU_bank_reg
(
    input wire clock,
    input wire reset,
    
    CPU_bank_reg_if.master request_if,
    CPU_bank_reg_if.slave response_if
);

integer i;
reg [`REG_WIDTH-1:0] reg_file [`NUM_REGS];

always @(posedge clock) begin
    if (reset) begin 
        for (i=0; i<`NUM_REGS; i=i+1) reg_file[i] <= 'h0;
    end else begin
        response_if.read_data_a <= reg_file[request_if.read_reg_a];
        response_if.read_data_b <= reg_file[request_if.read_reg_b];
        if (request_if.write_enable) reg_file[request_if.write_reg] <= request_if.write_data;
    end
end

endmodule
