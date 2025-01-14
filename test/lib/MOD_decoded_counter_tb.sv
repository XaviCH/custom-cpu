`include "CPU_define.vh"


module MOD_decoded_counter_tb ();
    localparam SIZE = 3;
    
    reg clock;
    reg reset;

    reg update;
    reg operation;
    reg [SIZE-1:0] out;

    MOD_decoded_counter #(
        .SIZE(SIZE)
    ) decoded_counter (
        .clock (clock),
        .reset (reset),
        .update (update),
        .operation (operation),
        .out (out)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        `ASSERT(out[0] == 1 && (|out[SIZE-1:1]) == 0);
        reset = 0;
        update = 1;
        operation = INCR;
        #20
        `ASSERT(out[0] == 0 && out[1] == 1 && (|out[SIZE-1:2]) == 0);
        update = 0;
        #20
        `ASSERT(out[0] == 0 && out[1] == 1 && (|out[SIZE-1:2]) == 0);
        update = 1;
        #20
        `ASSERT(out[SIZE-1] == 1 && (|out[SIZE-2:0]) == 0);
        operation = DECR;
        #20
        `ASSERT(out[0] == 0 && out[1] == 1 && (|out[SIZE-1:2]) == 0);
        update = 0;
        #20
        `ASSERT(out[0] == 0 && out[1] == 1 && (|out[SIZE-1:2]) == 0);
        update = 1;
        #20 // let reset a full cicle
        `ASSERT(out[0] == 1 && (|out[SIZE-1:1]) == 0);
        `SUCCESS;
    end

endmodule
