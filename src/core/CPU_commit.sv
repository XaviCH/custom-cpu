module CPU_commit;
(
    input wire clock;
    input wire reset;

    // input
    CPU_commit_if.slave commit_if,

    // output
    CPU_writeback_if.master writeback_if
);


endmodule