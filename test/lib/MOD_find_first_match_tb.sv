`include "CPU_define.vh"


module MOD_find_first_match_tb ();
    localparam SIZE = 3;
    localparam DATA_WIDTH = 16;
    
    reg [DATA_WIDTH-1:0] target;
    reg [DATA_WIDTH-1:0] data_in [SIZE];
    reg valid_in [SIZE];

    reg found;
    reg found_r;
    reg [$clog2(SIZE)-1:0] idx;
    reg [$clog2(SIZE)-1:0] idx_r;

    MOD_find_first_match #(
        .SIZE(SIZE),
        .DATA_WIDTH(DATA_WIDTH)
    ) find_first_match (
        .target (target),
        .data_in (data_in),
        .valid_in (valid_in),
        .found (found),
        .idx (idx)
    );

    MOD_find_first_match #(
        .SIZE(SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .REVERSE(1)
    ) find_first_match_reverse (
        .target (target),
        .data_in (data_in),
        .valid_in (valid_in),
        .found (found_r),
        .idx (idx_r)
    );

    initial begin
        target = 16'h0000;
        data_in[0] = 16'h0000; 
        data_in[1] = 16'haaaa; 
        data_in[2] = 16'hbbbb; 
        valid_in[0] = 0;
        valid_in[1] = 0;
        valid_in[2] = 0;
        #1
        `ASSERT(found == 0);
        `ASSERT(found_r == 0);
        valid_in[0] = 1;
        #1
        `ASSERT(idx == 0 && found == 1);
        `ASSERT(idx_r == 0 && found_r == 1);
        target = 16'haaaa; 
        #1
        `ASSERT(found == 0);
        `ASSERT(found_r == 0);
        valid_in[1] = 1;
        #1
        `ASSERT(idx == 1 && found == 1);
        `ASSERT(idx_r == 1 && found_r == 1);
        data_in[0] = 16'haaaa;
        #1 
        `ASSERT(idx == 0 && found == 1);
        `ASSERT(idx_r == 1 && found_r == 1);
        `SUCCESS;
    end

endmodule
