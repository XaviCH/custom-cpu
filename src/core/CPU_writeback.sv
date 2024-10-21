module CPU_writeback;
(
    input wire clock;
    input wire reset;

    // input
    CPU_writeback_if.slave writeback_if,
    CPU_FWUnit_input_if.master FWUnit_input_if,
    // output
    output wire reg_write,
    output wire [$clog2(NUM_REGS)] write_register,
    output wire [REG_WIDTH] write_data
);
assign FWUnit_input_if.write_back_wb <= writeback_if.writeback;


endmodule