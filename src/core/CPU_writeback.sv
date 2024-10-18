module CPU_writeback;
(
    input wire clock;
    input wire reset;

    // input
    CPU_writeback_if.slave commit_if,

    // output
    output wire reg_write,
    output wire [$clog2(NUM_REGS)] write_register,
    output wire [REG_WIDTH] write_data
);


endmodule