`include "CPU_define.vh"

module CPU_FW_unit_tb ();
    
    reg clock;
    reg reset;

    CPU_FWUnit_if FWUnit_if();

    CPU_FWUnit FWUnit
    (
        .clock(clock),
        .reset(reset),
        .FWUnit_if(FWUnit_if)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;

        #20
        FWUnit_if.master_writeback.rd_wb='h5;
        FWUnit_if.master_writeback.writeback_wb=1;
        FWUnit_if.master_execute.ra_id='h5;
        #20

        $display("ra bypass value: %h", FWUnit_if.master_execute.ra_bypass);
        $finish();
    end

endmodule
