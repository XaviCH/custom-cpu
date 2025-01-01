`include "CPU_define.vh"

module CPU_fetch_tb ();
    
    reg clock;
    reg reset;

    CPU_decode_if decode_if();
    CPU_commit_if commit_if();

    CPU_fetch fetch(
        .clock (clock),
        .reset (reset),
        .commit_if(commit_if),
        .decode_if(decode_if)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;
        #20

        commit_if.commit.branch=1;
        commit_if.zero=1;

        commit_if.branch_result=fetch.PC+'h10;
        #20

        $display("next PC value: %h", fetch.next_PC);

        $finish();
    end

endmodule
