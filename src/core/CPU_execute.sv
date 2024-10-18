module CPU_execute;
(
    input wire clock,
    input wire reset,

    // input
    CPU_decode_if.slave execute_if,
    
    // output
    CPU_commit_if.master commit_if,
);



endmodule