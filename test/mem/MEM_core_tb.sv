`include "CPU_define.vh"
`include "test/CPU_define.svh"
`include "mem/MEM_core.sv"

module MEM_core_tb ();

    localparam random_data = `LINE_WIDTH'hABCDEF01;
    localparam random_addr = 'h1;

    reg clock;
    reg reset;

    MEM_core_request_if core_request();
    MEM_core_response_if core_response();

    MEM_core memory_core(
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
        `SUCCESS;
    end

endmodule
