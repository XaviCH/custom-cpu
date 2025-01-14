`include "CPU_define.vh"
`include "test/CPU_define.svh"
`include "mem/MEM_core_bus.sv"

module MEM_core_bus_tb ();

    localparam random_data_0 = `LINE_WIDTH'hAAAAAAAA;
    localparam random_addr_0 = 0;
    localparam random_data_1 = `LINE_WIDTH'hBBBBBBBB;
    localparam random_addr_1 = 1;

    reg clock;
    reg reset;

    MEM_core_bus_request_if bus_request();
    MEM_core_bus_response_if bus_response();

    MEM_core_request_if core_request(); // mock
    MEM_core_response_if core_response(); // mock

    MEM_core_bus #(
        .MEM_LATENCY(2)
    ) memory_bus(
        .clock (clock),
        .reset (reset),
        .bus_request (bus_request),
        .core_request (core_request),
        .bus_response (bus_response),
        .core_response (core_response)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        `ASSERT_EQUAL(core_request.read, 0);
        `ASSERT_EQUAL(core_request.write, 0);
        `ASSERT_EQUAL(bus_response.valid, 0);
        reset = 0;
        // request program
        bus_request.id = '0;
        bus_request.read = '0; 
        bus_request.write = '1;
        bus_request.addr = random_addr_0;
        bus_request.data = random_data_0;
        #20
        `ASSERT_EQUAL(core_request.read, 0);
        `ASSERT_EQUAL(core_request.write, 0);
        `ASSERT_EQUAL(bus_response.valid, 0);
        bus_request.id = '1;
        bus_request.read = '0; 
        bus_request.write = '1;
        bus_request.addr = random_addr_1;
        bus_request.data = random_data_1;
        #20
        `ASSERT_EQUAL(core_request.read, 0);
        `ASSERT_EQUAL(core_request.write, 1);
        `ASSERT_EQUAL(core_request.addr, random_addr_0);
        `ASSERT_EQUAL(core_request.data, random_data_0);
        `ASSERT_EQUAL(bus_response.valid, 0);
        bus_request.id = '0;
        bus_request.read = '1; 
        bus_request.write = '0;
        bus_request.addr = random_addr_0;
        #20
        `ASSERT_EQUAL(core_request.read, 0);
        `ASSERT_EQUAL(core_request.write, 1);
        `ASSERT_EQUAL(core_request.addr, random_addr_1);
        `ASSERT_EQUAL(core_request.data, random_data_1);
        `ASSERT_EQUAL(bus_response.valid, 0);
        bus_request.id = '1;
        bus_request.read = '1; 
        bus_request.write = '0;
        bus_request.addr = random_addr_1;
        #20
        `ASSERT_EQUAL(core_request.read, 1);
        `ASSERT_EQUAL(core_request.write, 0);
        `ASSERT_EQUAL(core_request.addr, random_addr_0);
        `ASSERT_EQUAL(bus_response.valid, 0);
        bus_request.read = 0;
        core_response.valid = 1;
        core_response.addr = random_addr_0;
        core_response.data = random_data_0;
        #20
        `ASSERT_EQUAL(core_request.read, 1);
        `ASSERT_EQUAL(core_request.write, 0);
        `ASSERT_EQUAL(core_request.addr, random_addr_1);
        `ASSERT_EQUAL(bus_response.valid, 0);

        core_response.valid = 1;
        core_response.addr = random_addr_1;
        core_response.data = random_data_1;
        #20
        `ASSERT_EQUAL(core_request.read, 0);
        `ASSERT_EQUAL(core_request.write, 0);

        `ASSERT_EQUAL(bus_response.valid, 1);
        `ASSERT_EQUAL(bus_response.id, 0);
        `ASSERT_EQUAL(bus_response.addr, random_addr_0);
        `ASSERT_EQUAL(bus_response.data, random_data_0);
        #20
        `ASSERT_EQUAL(core_request.read, 0);
        `ASSERT_EQUAL(core_request.write, 0);

        `ASSERT_EQUAL(bus_response.valid, 1);
        `ASSERT_EQUAL(bus_response.id, 1);
        `ASSERT_EQUAL(bus_response.addr, random_addr_1);
        `ASSERT_EQUAL(bus_response.data, random_data_1);
        `SUCCESS;
    end

endmodule
