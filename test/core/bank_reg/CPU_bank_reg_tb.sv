`include "CPU_define.vh"

module CPU_bank_reg_tb ();
    
    reg clock;
    reg reset;

    CPU_bank_reg_if bank_reg_if();

    CPU_bank_reg bank_reg(
        .clock (clock),
        .reset (reset),
        .bank_reg_if(bank_reg_if)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;
        // load program
        bank_reg_if.write_enable=1;
        bank_reg_if.write_reg=2;
        bank_reg_if.write_data=2;
        #20

        $display("reg written: %h", bank_reg.reg_file[2]);

        bank_reg_if.read_reg_a=2;
        bank_reg_if.read_reg_b=1;
        #20

    
        $display("reg a value: %h, reg b value: %h", bank_reg_if.read_data_a, bank_reg_if.slave.read_data_b);

        bank_reg_if.write_enable=1;
        bank_reg_if.write_reg=1;
        bank_reg_if.write_data=20;
        #20

        bank_reg_if.read_reg_a=2;
        bank_reg_if.read_reg_b=1;
        #20

        $display("reg a value: %h, reg b value: %h", bank_reg_if.read_data_a, bank_reg_if.slave.read_data_b);

        reset = 1;
        bank_reg_if.write_enable=0;

        #20
        reset = 0;
        
        bank_reg_if.read_reg_a=2;
        bank_reg_if.read_reg_b=1;
        #20

        $display("reg a value: %h, reg b value: %h", bank_reg_if.read_data_a, bank_reg_if.slave.read_data_b);
        $finish();
    end

endmodule
