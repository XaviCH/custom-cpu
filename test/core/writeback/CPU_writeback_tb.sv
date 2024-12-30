`include "CPU_define.vh"

module CPU_writeback_tb ();
    
    reg clock;
    reg reset;

    CPU_bank_reg_if bank_reg_if();

    CPU_bank_reg bank_reg(
        .clock (clock),
        .reset (reset),
        .bank_reg_if(bank_reg_if)
    );

    CPU_writeback_if writeback_if();

    CPU_writeback writeback(
        .clock (clock),
        .reset (reset),
        .writeback_if(writeback_if),
        .bank_reg_if(bank_reg_if)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;
        bank_reg.reg_file[1]='h4;
        #20
        // load program
        writeback_if.writeback.mem_to_reg=0;
        writeback_if.writeback.reg_write=1;
        writeback_if.reg_dest=1;
        writeback_if.alu_data=1;
        
        $display("reg value: %h", bank_reg.reg_file[1]);
        
        #20

        $display("reg value: %h", bank_reg.reg_file[1]);
        $finish();
    end

endmodule
