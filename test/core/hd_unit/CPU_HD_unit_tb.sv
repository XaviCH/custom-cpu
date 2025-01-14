`include "CPU_define.vh"

module CPU_HD_unit_tb ();
    
    reg clock;
    reg reset;

    CPU_HDUnit_if HDUnit_if();

    CPU_HDUnit HDUnit
    (
        .clock(clock),
        .reset(reset),
        .HDUnit_if(HDUnit_if)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;
        #20 // let reset a full cicle
        HDUnit_if.execute_mem_read=1;
        HDUnit_if.execute_rd=5;

        HDUnit_if.decode_ra=5;
        HDUnit_if.ra_use=1;
        #20 // let reset a full cicle

        $display("stall value: %h", HDUnit_if.stall);
        $finish();
    end

endmodule
