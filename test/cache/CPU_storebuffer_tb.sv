`include "test/CPU_define.svh"
`include "cache/CPU_storebuffer.sv"

module CPU_storebuffer_tb ();
    
    localparam SIZE = 4;
    localparam TAG_WIDTH = 16;
    localparam DATA_WIDTH = `WORD_WIDTH;
    localparam BYTES_IN_DATA = DATA_WIDTH/`BYTE_WIDTH;

    reg clock;
    reg reset;

    logic operation;
    logic pop;
    logic [TAG_WIDTH-1:0] tag_in;
    logic [DATA_WIDTH-1:0] data_in;
    cache_mode_e mode;


    logic [BYTES_IN_DATA-1:0] hit_lines;
    logic [BYTES_IN_DATA-1:0] hit_bytes_pop;
    logic [TAG_WIDTH-1:0] tag_pop;
    logic [DATA_WIDTH-1:0] data_pop;
    logic empty;
    logic full;
    logic [BYTES_IN_DATA-1:0] hit_bytes;
    logic [DATA_WIDTH-1:0] data_response;

    CPU_storebuffer #(
        .SIZE(SIZE),
        .TAG_WIDTH(TAG_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) storebuffer (
        .clock (clock),
        .reset (reset),
        .operation(operation),
        .mode(mode),
        .pop(pop),
        .tag_in(tag_in),
        .data_in(data_in),
        .hit_lines(hit_lines),
        .hit_bytes_pop(hit_bytes_pop),
        .tag_pop(tag_pop),
        .data_pop(data_pop),
        .empty(empty),
        .full(full),
        .hit_bytes(hit_bytes),
        .data_response(data_response)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        `ASSERT(empty == 1 && hit_bytes == 0 && full == 0);
        reset = 0;
        mode = WORD;
        operation = REQUEST;
        pop = 0;
        tag_in = 0;
        data_in = 0;
        #20
        `ASSERT(empty == 1 && hit_bytes == 0 && full == 0);
        operation = PUSH;
        tag_in = 'h10;
        data_in = 'h11223344;
        #20
        `ASSERT(empty == 0 && full == 0);
        `ASSERT_EQUAL(tag_pop, 'h10);
        `ASSERT_EQUAL(data_pop, 'h11223344);
        mode = HALF;
        tag_in = 'h12;
        data_in = 'h55667788;
        #20
        `ASSERT(empty == 0 && full == 0);
        `ASSERT_EQUAL(tag_pop, 'h10);
        `ASSERT_EQUAL(data_pop, 'h11223344);
        mode = BYTE;
        tag_in = 'h13;
        data_in = 'h99AABBCC;
        #20
        `ASSERT(empty == 0 && full == 0);
        `ASSERT_EQUAL(tag_pop, 'h10);
        `ASSERT_EQUAL(data_pop, 'h11223344);
        mode = BYTE;
        tag_in = 'h11;
        data_in = 'h99AABBCC;
        #20
        `ASSERT(empty == 0 && full == 1);
        `ASSERT_EQUAL(tag_pop, 'h10);
        `ASSERT_EQUAL(data_pop, 'h11223344);
        operation = REQUEST;
        mode = WORD;
        #20
        `ASSERT(empty == 0 && full == 1);
        `ASSERT_EQUAL(tag_pop, 'h10);
        `ASSERT_EQUAL(data_pop, 'h11223344);
        `ASSERT_EQUAL(hit_bytes, 'hf);
        `ASSERT_EQUAL(data_response, 'hCC88CC44);
        pop = 1;
        #20
        `ASSERT(empty == 0 && full == 0);
        `ASSERT_EQUAL(tag_pop, 'h10);
        `ASSERT_EQUAL(data_pop, 'h77880000);
        `ASSERT_EQUAL(hit_bytes_pop, 'b1100);
        `ASSERT_EQUAL(hit_bytes, 'b1110);
        `ASSERT_EQUAL(data_response[DATA_WIDTH-1:`BYTE_WIDTH], 'hCC88CC);
        #20
        `ASSERT(empty == 0 && full == 0);
        `ASSERT_EQUAL(tag_pop, 'h10);
        `ASSERT_EQUAL(data_pop, 'hcc000000);
        `ASSERT_EQUAL(hit_bytes_pop, 'b1000);
        `ASSERT_EQUAL(hit_bytes, 'b1010);
        `ASSERT_EQUAL(data_response[`BYTE_WIDTH*2-1:`BYTE_WIDTH], 'hCC);
        `ASSERT_EQUAL(data_response[`BYTE_WIDTH*4-1:`BYTE_WIDTH*3], 'hCC);
        #20
        `ASSERT(empty == 0 && full == 0);
        `ASSERT_EQUAL(tag_pop, 'h10);
        `ASSERT_EQUAL(data_pop[`BYTE_WIDTH*2-1:`BYTE_WIDTH], 'hcc);
        `ASSERT_EQUAL(hit_bytes_pop, 'b0010);
        `ASSERT_EQUAL(hit_bytes, 'b0010);
        `ASSERT_EQUAL(data_response[`BYTE_WIDTH*2-1:`BYTE_WIDTH], 'hCC);
        #20
        `ASSERT_EQUAL(empty, 1);
        `ASSERT_EQUAL(hit_bytes, 0);
        `SUCCESS;
    end

endmodule
