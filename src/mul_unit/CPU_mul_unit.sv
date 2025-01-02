`include "CPU_define.vh"

module CPU_mul_unit
(
    input wire clock,
    input wire reset,
    
    CPU_writeback_if.master writeback_if,
    CPU_mul_unit_if.slave mul_unit_if
);

typedef struct packed {
    logic stage_wb;
    logic [$clog2(`NUM_REGS)-1:0] rd_id;
    logic [`REG_WIDTH-1:0] stage_value;
} mul_stage_t;


mul_stage_t stages[`MUL_STAGES];


always @(posedge clock, posedge reset) begin
    if (reset) begin 
        for (i=0; i<`MUL_STAGES; i=i+1) stages[i] <= 0;
    end else begin
        //TODO writeback (double write port?)

        stages[4]<=stages[3];
        stages[3]<=stages[2];
        stages[2]<=stages[1];
        stages[1]<=stages[0];

        stages[0].stage_wb<=mul_unit_if.stage_wb;
        stages[0].rd_id<=mul_unit_if.rd_id;
        stages[0].stage_value<=mul_unit_if.ra_data*mul_unit_if.rb_data;
    end
end

endmodule