`include "CPU_define.vh"

module CPU_mul_unit
(
    input wire clock,
    input wire reset,
    
    CPU_writeback_if.master_mul writeback_if,
    CPU_mul_unit_if.slave mul_unit_if
);

typedef struct packed {
    logic writeback_mul;
    logic [$clog2(`NUM_REGS)-1:0] rd_id;
    logic [`REG_WIDTH-1:0] mul_result;
} writeback_mul_t;

writeback_mul_t mul_stages[`MUL_STAGES];

assign mul_stages[0].writeback_mul = mul_unit_if.writeback_mul;
assign mul_stages[0].rd_id = mul_unit_if.rd_id;
assign mul_stages[0].mul_result= mul_unit_if.ra_data * mul_unit_if.rb_data;

integer i;

always @(posedge clock, posedge reset) begin
    if (reset) begin 
        for (i=0; i<`MUL_STAGES; i=i+1) mul_stages[i] <= 0;
    end else begin
        //TODO writeback (double write port?)
        writeback_if.writeback_mul <= mul_stages[4];
        mul_stages[4]<=mul_stages[3];
        mul_stages[3]<=mul_stages[2];
        mul_stages[2]<=mul_stages[1];
        mul_stages[1]<=mul_stages[0];
    end
end

endmodule