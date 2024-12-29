`include "CPU_define.vh"

module CPU_decode_tb ();
    
    reg clock;
    reg reset;

    CPU_bank_reg_if bank_request_if();

    CPU_bank_reg bank_reg(
        .clock (clock),
        .reset (reset),
        .bank_reg_if(bank_request_if)
    );

    CPU_decode_if decode_if();
    CPU_execute_if execute_if();

    CPU_decode decode(
        .clock (clock),
        .reset (reset),
        .bank_reg_request_if(bank_request_if),
        .decode_if(decode_if),
        .execute_if(execute_if)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;
        bank_reg.reg_file[1]='h4;
        bank_reg.reg_file[2]='h5;
        // load program
        decode_if.master.next_PC='h1;
        decode_if.master.instr={7'h0, 5'h0, 5'h2, 5'h1, 10'h00};
        #20

        $display("reg a value: %h, reg b value: %h", execute_if.ra_data, execute_if.slave.rb_data);
        $finish();
    end

endmodule
