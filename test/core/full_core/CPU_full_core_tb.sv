`include "CPU_define.vh"

module CPU_full_core_tb ();
    
    reg clock;
    reg reset;

    CPU_bank_reg_if bank_reg_if();
    CPU_FWUnit_if FWUnit_if();
    CPU_HDUnit_if HDUnit_if();

    CPU_fetch_if fetch_if();
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

    CPU_fetch fetch(
        .clock (clock),
        .reset (reset),
        .fetch_if(fetch_if),
        .HDUnit_if(HDUnit_if),
        .decode_if(decode_if)
    );

    CPU_decode decode(
        .clock (clock),
        .reset (reset),
        .fetch_if(fetch_if),
        .bank_reg_if(bank_reg_if),
        .FWUnit_if(FWUnit_if),
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
    // decode_if.instr={7'h0, 5'h1, 5'h2, 5'h1, 10'h00};

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        bank_reg.reg_file[1] = 1;
        bank_reg.reg_file[2] = 2;
        bank_reg.reg_file[3] = 3;
        bank_reg.reg_file[4] = 4;
        bank_reg.reg_file[5] = 5;
        reset = 0;

        $display("\n");
        $display("fetch->decode");
        $display("PC value: %h", fetch.PC);
        $display("decode ins value: %h", decode_if.instr);
        $display("alu ra data: %h", execute.ra_value);
        $display("alu rb data: %h", execute.rb_value);
        $display("alu result value: %h", commit_if.alu_result);
                //DEBUG
        $display("commit wb: %h", commit_if.writeback.reg_write);
        $display("writeback reg_dest: %h", writeback_if.reg_dest);
        $display("reg_1 value: %h", bank_reg.reg_file[1]);
        $display("rb bypass: %h", FWUnit_if.rb_execute_bypass);
        $display("stall cpu: %h", HDUnit_if.stall);
        $display("nop cpu: %h", decode_if.nop);
        
        #20 // let reset a full cicle
        reset = 0;
        $display("\n");
        $display("decode->alu");
        $display("PC value: %h", fetch.PC);
        $display("decode ins value: %h", decode_if.instr);
        $display("alu ra data: %h", execute_if.ra_data);
        $display("alu rb data: %h", execute.rb_value);
        $display("alu result value: %h", commit_if.alu_result);
        $display("writeback reg_dest: %h", writeback_if.reg_dest);
        $display("reg_1 value: %h", bank_reg.reg_file[1]);
        $display("rb bypass: %h", FWUnit_if.rb_execute_bypass);
        $display("stall cpu: %h", HDUnit_if.stall);
        $display("nop cpu: %h", decode_if.nop);



        #20 // let reset a full cicle
        $display("\n");
        $display("alu->mem");
        reset = 0;
        $display("PC value: %h", fetch.PC);
        $display("decode ins value: %h", decode_if.instr);
        $display("alu ra data: %h", execute_if.ra_data);
        $display("alu rb data: %h", execute.rb_value);
        $display("alu result value: %h", commit_if.alu_result);
        $display("writeback reg_dest: %h", writeback_if.reg_dest);
        $display("reg_1 value: %h", bank_reg.reg_file[1]);
        $display("rb bypass: %h", FWUnit_if.rb_execute_bypass);
        $display("stall cpu: %h", HDUnit_if.stall);
        $display("nop cpu: %h", decode_if.nop);



        #20 // let reset a full cicle
        $display("\n");
        $display("mem->wb");
        reset = 0;
        $display("PC value: %h", fetch.PC);
        $display("decode ins value: %h", decode_if.instr);
        $display("alu ra data: %h", execute_if.ra_data);
        $display("alu rb data: %h", execute.rb_value);
        $display("alu result value: %h", commit_if.alu_result);
        $display("writeback reg_dest: %h", writeback_if.reg_dest);
        $display("reg_1 value: %h", bank_reg.reg_file[1]);
        $display("rb bypass: %h", FWUnit_if.rb_execute_bypass);
        $display("use rb: %h", execute_if.execute.use_reg_b);
        $display("stall cpu: %h", HDUnit_if.stall);
        $display("reg_a value: %h", decode.ra_value_br);
        $display("reg_b value: %h", decode.rb_value_br);

        $display("ra dec bypass: %h", FWUnit_if.ra_decode_bypass);
        $display("rb dec bypass: %h", FWUnit_if.rb_decode_bypass);




        #20 // let reset a full cicle
        $display("\n");
        $display("wb");
        reset = 0;
        $display("PC value: %h", fetch.PC);
        $display("decode ins value: %h", decode_if.instr);
        $display("alu ra data: %h", execute_if.ra_data);
        $display("alu rb data: %h", execute.rb_value);
        $display("alu result value: %h", commit_if.alu_result);
        $display("writeback reg_dest: %h", writeback_if.reg_dest);
        $display("reg_1 value: %h", bank_reg.reg_file[1]);
        $display("rb bypass: %h", FWUnit_if.rb_execute_bypass);
        $display("stall cpu: %h", HDUnit_if.stall);



        #20 // let reset a full cicle
        $display("\n");
        $display("wb+1");
        reset = 0;
        $display("PC value: %h", fetch.PC);
        $display("decode ins value: %h", decode_if.instr);
        $display("alu ra data: %h", execute_if.ra_data);
        $display("alu rb data: %h", execute.rb_value);
        $display("alu result value: %h", commit_if.alu_result);
        $display("writeback reg_dest: %h", writeback_if.reg_dest);
        $display("reg_1 value: %h", bank_reg.reg_file[1]);
        $display("rb bypass: %h", FWUnit_if.rb_execute_bypass);
        $display("stall cpu: %h", HDUnit_if.stall);


        #20 // let reset a full cicle
        $display("\n");
        $display("wb+2");
        reset = 0;
        $display("PC value: %h", fetch.PC);
        $display("decode ins value: %h", decode_if.instr);
        $display("alu ra data: %h", execute_if.ra_data);
        $display("alu rb data: %h", execute.rb_value);
        $display("alu result value: %h", commit_if.alu_result);
        $display("writeback reg_dest: %h", writeback_if.reg_dest);
        $display("reg_1 value: %h", bank_reg.reg_file[1]);
        $display("rb bypass: %h", FWUnit_if.rb_execute_bypass);
        $display("stall cpu: %h", HDUnit_if.stall);



        #20 // let reset a full cicle
        $display("\n");
        $display("wb+3");
        reset = 0;
        $display("PC value: %h", fetch.PC);
        $display("decode ins value: %h", decode_if.instr);
        $display("alu ra data: %h", execute_if.ra_data);
        $display("alu rb data: %h", execute.rb_value);
        $display("alu result value: %h", commit_if.alu_result);
        $display("writeback reg_dest: %h", writeback_if.reg_dest);
        $display("reg_1 value: %h", bank_reg.reg_file[1]);
        $display("rb bypass: %h", FWUnit_if.rb_execute_bypass);


        $finish();
    end

endmodule
