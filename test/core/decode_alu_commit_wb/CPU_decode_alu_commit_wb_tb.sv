`include "CPU_define.vh"

module CPU_decode_alu_commit_wb_tb ();
    
    reg clock;
    reg reset;

    CPU_bank_reg_if bank_reg_if();
    CPU_FWUnit_if FWUnit_if();
    CPU_HDUnit_if HDUnit_if();
    CPU_decode_if decode_if();
    CPU_execute_if execute_if();
    CPU_commit_if commit_if();
    CPU_writeback_if writeback_if();

    CPU_bank_reg bank_reg(
        .clock (clock),
        .reset (reset),
        .bank_reg_if(bank_reg_if)
    );

    CPU_FWUnit FWUnit
    (
        .clock(clock),
        .reset(reset),
        .FWUnit_if(FWUnit_if)
    );

    CPU_HDUnit HDUnit
    (
        .clock(clock),
        .reset(reset),
        .HDUnit_if(HDUnit_if)
    );

    CPU_decode decode(
        .clock (clock),
        .reset (reset),
        .bank_reg_if(bank_reg_if),
        .HDUnit_if(HDUnit_if),
        .decode_if(decode_if),
        .execute_if(execute_if)
    );


    CPU_execute execute(
        .clock (clock),
        .reset (reset),
        .execute_if(execute_if),
        .FWUnit_if(FWUnit_if),
        .HDUnit_if(HDUnit_if),
        .commit_if(commit_if)
    );
    

    CPU_commit commit(
        .clock (clock),
        .reset (reset),
        .commit_if(commit_if),
        .FWUnit_if(FWUnit_if),
        .writeback_if(writeback_if)
    );

    CPU_writeback writeback(
        .clock (clock),
        .reset (reset),
        .writeback_if(writeback_if),
        .bank_reg_if(bank_reg_if),
        .FWUnit_if(FWUnit_if)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;
        bank_reg.reg_file[1]='h4;
        bank_reg.reg_file[2]='h5;
        // load program
        // decode_if.master.next_PC='h1;
        // decode_if.master.instr.r_instr.opcode=opcode_t'ADD;
        // decode_if.master.instr.r_instr.dst=2;
        // decode_if.master.instr.r_instr.src1=1;
        // decode_if.master.instr.r_instr.src2=2;

        decode_if.instr={7'h0, 5'h1, 5'h2, 5'h1, 10'h00};

        #20

        $display("ra bypass value: %h", FWUnit_if.master_execute.ra_bypass);
        $display("rb bypass value: %h", FWUnit_if.master_execute.rb_bypass);

        $display("ra execute id: %h", execute_if.ra_id);
        $display("rb execute id: %h", execute_if.rb_id);
        $display("rd execute id: %h", execute_if.reg_dest);

        $display("reg a value: %h, reg b value: %h, result_value: %h", execute_if.ra_data, execute_if.rb_data, commit_if.alu_result);

        #20
        $display("ra bypass value: %h", FWUnit_if.master_execute.ra_bypass);

        $display("use rb: %h", execute_if.execute.use_reg_b);
        $display("rb bypass: %h", FWUnit_if.rb_bypass);

        $display("reg a value: %h, reg b value: %h, result_value: %h", execute_if.ra_data, execute.rb_value, commit_if.alu_result);

        #20
        $display("ra bypass value: %h", FWUnit_if.master_execute.ra_bypass);

        $display("reg a value: %h, reg b value: %h, result_value: %h", execute_if.ra_data, execute.rb_value, commit_if.alu_result);

        #20
        $display("ra bypass value: %h", FWUnit_if.master_execute.ra_bypass);

        $display("reg a value: %h, reg b value: %h, result_value: %h", execute_if.ra_data, execute.rb_value, commit_if.alu_result);

        $finish();
    end

endmodule
