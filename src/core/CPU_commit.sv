module CPU_commit;
(
    input wire clock;
    input wire reset;

    // input
    CPU_commit_if.slave commit_if,

    // output
    CPU_FWUnit_output_if.master FWUnit_output_if
    CPU_writeback_if.master writeback_if
);

assign FWUnit_input_if.write_back_commit <= commit_if.writeback;


endmodule