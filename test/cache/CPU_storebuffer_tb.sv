`include "CPU_define.vh"
`include "CPU_types.vh"

module CPU_storebuffer_tb ();
    
    localparam SIZE = 3;
    localparam TAG_WIDTH = 16;
    localparam DATA_WIDTH = 16;

    reg clock;
    reg reset;

    logic operation;
    logic pop;
    logic [TAG_WIDTH-1:0] tag_in;
    logic [DATA_WIDTH-1:0] data_in;

    logic [TAG_WIDTH-1:0] tag_pop;
    logic [DATA_WIDTH-1:0] data_pop;
    logic empty;
    logic full;
    logic hit;
    logic [DATA_WIDTH-1:0] data_response;

    CPU_storebuffer #(
        .SIZE(SIZE),
        .TAG_WIDTH(TAG_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) storebuffer (
        .clock (clock),
        .reset (reset),
        .operation(operation),
        .pop(pop),
        .tag_in(tag_in),
        .data_in(data_in),
        .tag_pop(tag_pop),
        .data_pop(data_pop),
        .empty(empty),
        .full(full),
        .hit(hit),
        .data_response(data_response)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        `ASSERT(empty == 1 && hit == 0 && full == 0);
        reset = 0;
        operation = REQUEST;
        pop = 0;
        tag_in = 0;
        data_in = 0;
        #20
        `ASSERT(empty == 1 && hit == 0 && full == 0);
        operation = PUSH;
        tag_in = 'h10;
        data_in = 'ha;
        #20
        `ASSERT(empty == 0 && full == 0);
        operation = REQUEST;
        pop = 1;
        `ASSERT(tag_pop == 'h10);
        `ASSERT(data_pop == 'ha);
        #20
        `ASSERT(data_response == 'ha);
        `ASSERT(empty == 0 && hit == 1 && full == 0);
        pop = 0;
        operation = PUSH;
        #20
        data_in = 'hb;
        #20
        `ASSERT(empty == 0 && hit == 1 && full == 0);
        data_in = 'hc;
        #20
        `ASSERT(empty == 0 && hit == 1 && full == 1);
        operation = REQUEST;
        #20
        `ASSERT(empty == 0 && hit == 1 && full == 1);
        `ASSERT(data_response == 'hc);
        `SUCCESS;
    end

endmodule
