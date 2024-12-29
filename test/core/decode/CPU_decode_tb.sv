`include "CPU_define.vh"

module CPU_decode_tb ();
    
    reg clock;
    reg reset;

    CPU_bank_reg_if bank_reg_if();

    CPU_bank_reg bank_reg(
        .clock (clock),
        .reset (reset),
        .bank_reg_if(bank_reg_if)
    );

    CPU_decode_if decode_if();
    CPU_execute_if execute_if();

    CPU_decode decode(
        .clock (clock),
        .reset (reset),
        .bank_reg_if(bank_reg_if),
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
        decode_if.master.instr={7'h1, 5'h0, 5'h2, 5'h1, 10'h00};
        #20


        $display("instr value: %h, reg_b value: %h", decode_if.master.instr.r_instr.opcode, execute_if.reg_b);
        $display("reg a value: %h, reg b value: %h", execute_if.ra_data, execute_if.slave.rb_data);
        $display("instr src1 value: %b, src2 value: %b", decode_if.master.instr.r_instr.src1, decode_if.master.instr.r_instr.src2);
        $display("alu op: %b", execute_if.execute.alu_op);
        $finish();
    end

endmodule
