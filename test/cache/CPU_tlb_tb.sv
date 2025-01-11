`include "CPU_define.vh"
`include "test/CPU_define.svh"
`include "cache/CPU_tlb.sv"

module CPU_tlb_tb ();
    localparam SIZE = 3;
    localparam KEY_WIDTH = 16;
    localparam VALUE_WIDTH = 16;

    reg clock;
    reg reset;

    logic [KEY_WIDTH-1:0] key; 
    logic [VALUE_WIDTH-1:0] value; 
    logic write;

    logic [VALUE_WIDTH-1:0] out;
    logic hit;

    CPU_tlb #(
        .SIZE(SIZE),
        .KEY_WIDTH(KEY_WIDTH),
        .VALUE_WIDTH(VALUE_WIDTH)
    ) tlb(
        .clock (clock),
        .reset (reset),
        .key (key),
        .value (value),
        .write (write),
        .out (out),
        .hit (hit)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;
        write = 0;
        key = 'h10;
        #20
        `ASSERT(hit == 0);
        write = 1;
        value = 'h20;
        #20
        key = 'h11;
        value = 'h21;
        #20
        key = 'h12;
        value = 'h22;
        #20
        write = 0;
        #20
        `ASSERT(hit == 1 && out == 'h22);
        key = 'h11;
        #20
        `ASSERT_EQUAL(hit, 1);
        `ASSERT_EQUAL(out, 'h21);
        key = 'h10;
        #20
        `ASSERT(hit == 1 && out == 'h20);
        key = 'h9;
        #20
        `ASSERT(hit == 0);
        write = 1;
        #20
        write = 0;
        key = 'h10;
        value = 'h29;
        #20
        `ASSERT(hit == 0);
        key = 'h9;
        #20
        `ASSERT(hit == 1 && value == 'h29);
        `SUCCESS;
    end

endmodule
