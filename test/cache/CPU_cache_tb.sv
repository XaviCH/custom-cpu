`include "test/CPU_define.svh"
`include "cache/CPU_cache.sv"

module CPU_cache_tb ();
    
    reg clock;
    reg reset;

    CPU_cache_request_if cache_request();
    CPU_cache_response_if cache_response();
    logic mem_bus_available;
    CPU_mem_bus_request_if bus_request();
    CPU_mem_bus_response_if bus_response();

    CPU_cache cache(
        .clock (clock),
        .reset (reset),
        .cache_request (cache_request),
        .cache_response (cache_response),
        .mem_bus_available (mem_bus_available),
        .mem_bus_request (bus_request),
        .mem_bus_response (bus_response)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        mem_bus_available = 1;
        #20 // let reset a full cicle
        `ASSERT_EQUAL(cache_response.hit, 0);
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        reset = 0;
        mem_bus_available = 0;
        bus_response.valid = 0;
        cache_request.read = '1;
        cache_request.write = '0;
        cache_request.addr = 'h0;
        cache_request.mode = WORD;
        #20
        `ASSERT_EQUAL(cache_response.hit, 0);
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        mem_bus_available = 1;
        #20
        `ASSERT_EQUAL(cache_response.hit, 0);
        `ASSERT_EQUAL(bus_request.read, 1);
        `ASSERT_EQUAL(bus_request.write, 0);
        `ASSERT_EQUAL(bus_request.addr, 'h0);
        #20
        `ASSERT_EQUAL(cache_response.hit, 0);
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        cache_request.read = 0;
        cache_request.write = 1;
        cache_request.data = 'h11223344;
        mem_bus_response.valid = 1;
        mem_bus_response.addr = 'h0;
        mem_bus_response.data = 'hFFEEDDCCFFEEDDCCFFEEDDCCFFEEDDCC;
        #20
        `ASSERT_EQUAL(cache_response.hit, 1);
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #20 
        mem_response_if.valid = '1;
        mem_response_if.addr = mem_request_if.addr;
        mem_response_if.data = 128'hDDDDDDDDCCCCCCCCBBBBBBBBAAAAAAAA;
        $display("mem request. read: %b, write: %b, addr: %h", mem_request_if.read, mem_request_if.write, mem_request_if.addr);
        $display("cache response. valid: %b, data: %h", cache_response_if.hit, cache_response_if.data);
        #20
        $display("mem request. read: %b, write: %b, addr: %h", mem_request_if.read, mem_request_if.write, mem_request_if.addr);
        $display("cache response. valid: %b, data: %h", cache_response_if.hit, cache_response_if.data);
        #20
        cache_request_if.addr = 'h4;
        $display("mem request. read: %b, write: %b, addr: %h", mem_request_if.read, mem_request_if.write, mem_request_if.addr);
        $display("cache response. valid: %b, data: %h", cache_response_if.hit, cache_response_if.data);
        #20
        cache_request_if.addr = 'h8;
        $display("mem request. read: %b, write: %b, addr: %h", mem_request_if.read, mem_request_if.write, mem_request_if.addr);
        $display("cache response. valid: %b, data: %h", cache_response_if.hit, cache_response_if.data);
        #20
        cache_request_if.addr = 'hc;
        $display("mem request. read: %b, write: %b, addr: %h", mem_request_if.read, mem_request_if.write, mem_request_if.addr);
        $display("cache response. valid: %b, data: %h", cache_response_if.hit, cache_response_if.data);
        #20
        $display("mem request. read: %b, write: %b, addr: %h", mem_request_if.read, mem_request_if.write, mem_request_if.addr);
        $display("cache response. valid: %b, data: %h", cache_response_if.hit, cache_response_if.data);
        $finish();
    end

endmodule
