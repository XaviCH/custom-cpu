`include "CPU_define.vh"
`include "test/CPU_define.svh"
`include "mem/MEM_core.sv"

module MEM_core_tb ();

    localparam int NUM_CODES = 2;
    localparam int CODE_ADDRS[NUM_CODES] = {0, 2};
    localparam int CODE_START_INSTR[NUM_CODES] = {0, 4};
    localparam int TOTAL_INSTR = 8;
    localparam [`INSTR_WIDTH-1:0] CODE_INSTR_DATAS[TOTAL_INSTR] = {
        'ha,
        'h2,
        'h3,
        'h4,
        'hb,
        'h5,
        'h6,
        'h7
    };

    localparam random_data = `LINE_WIDTH'hABCDEF01;
    localparam random_addr = 'h1;

    reg clock;
    reg reset;

    MEM_core_request_if core_request();
    MEM_core_response_if core_response();

    MEM_core #(
        .NUM_CODES(NUM_CODES),
        .CODE_ADDRS(CODE_ADDRS),
        .CODE_START_INSTR(CODE_START_INSTR),
        .TOTAL_INSTR(TOTAL_INSTR),
        .CODE_INSTR_DATAS(CODE_INSTR_DATAS)
    ) memory_core (
        .clock (clock),
        .reset (reset),
        .core_request (core_request),
        .core_response (core_response)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        `ASSERT_EQUAL(core_response.valid, 0);
        reset = 0;
        // load program
        core_request.read = '0; 
        core_request.write = '1;

        core_request.addr = random_addr;
        core_request.data = random_data;
        #20
        `ASSERT_EQUAL(core_response.valid, 0);
        core_request.read = '1; 
        core_request.write = '0;
        #20
        `ASSERT_EQUAL(core_response.valid, 1);
        `ASSERT_EQUAL(core_response.data, random_data);
        `ASSERT_EQUAL(core_response.addr, random_addr);
        core_request.addr = 'h0;
        #20
        `ASSERT_EQUAL(core_response.valid, 1);
        `ASSERT_EQUAL(core_response.addr, 'h0);
        `ASSERT_EQUAL(core_response.data, {CODE_INSTR_DATAS[3], CODE_INSTR_DATAS[2], CODE_INSTR_DATAS[1], CODE_INSTR_DATAS[0]});
        core_request.addr = 'h2;
        #20
        `ASSERT_EQUAL(core_response.valid, 1);
        `ASSERT_EQUAL(core_response.addr, 'h2);
        `ASSERT_EQUAL(core_response.data, {CODE_INSTR_DATAS[7], CODE_INSTR_DATAS[6], CODE_INSTR_DATAS[5], CODE_INSTR_DATAS[4]});
        `SUCCESS;
    end

endmodule
