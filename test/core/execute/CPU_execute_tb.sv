`include "CPU_define.vh"

module CPU_execute_tb ();
    
    reg clock;
    reg reset;

    CPU_execute_if execute_if();
    CPU_commit_if commit_if();

    CPU_execute execute(
        .clock (clock),
        .reset (reset),
        .execute_if(execute_if),
        .commit_if(commit_if)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;
        execute_if.ra_data=2;
        execute_if.rb_data=3;
        execute_if.reg_b=1;
        execute_if.execute.alu_op='b0;
        #20

        $display("reg a value: %h, reg b value: %h, result_value: %h", execute_if.ra_data, execute_if.slave.rb_data, commit_if.alu_result);
        $finish();
    end

endmodule
