`include "test/CPU_define.svh"
`include "core/CPU_fetch.sv"

module CPU_fetch_tb ();
    
    reg clock;
    reg reset;

    CPU_fetch_if fetch_if();
    logic mem_bus_available;
    CPU_mem_bus_request_if bus_request();
    CPU_mem_bus_response_if bus_response();

    CPU_fetch fetch(
        .clock (clock),
        .reset (reset),
        .fetch_request (fetch_if),
        .fetch_response (fetch_if),
        .mem_bus_available (mem_bus_available),
        .mem_bus_request (bus_request),
        .mem_bus_response (bus_response)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        mem_bus_available = 1;
        #20 // let reset a full cicle
        `ASSERT_EQUAL(fetch_if.tlb_hit, 0);
        `ASSERT_EQUAL(fetch_if.cache_hit, 0);
        `ASSERT_EQUAL(bus_request.read, 1);
        `ASSERT_EQUAL(bus_request.write, 0);
        reset = 0;
        fetch_if.tlb_enable = 0;
        mem_bus_available = 0;
        bus_response.valid = 0;
        fetch_if.pc = '0;
        fetch_if.jump = '0;
        fetch_if.exception = '0;
        #10 // test wire, expect external component to catch
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10 // test regs, 
        `ASSERT_EQUAL(fetch_if.cache_hit, 0);
        `ASSERT_EQUAL(fetch_if.next_pc, 'h4);
        mem_bus_available = 1;
        #10 // test wire
        `ASSERT_EQUAL(bus_request.read, 1);
        `ASSERT_EQUAL(bus_request.write, 0);
        `ASSERT_EQUAL(bus_request.addr, 'h0);
        #10 // test reg
        `ASSERT_EQUAL(fetch_if.cache_hit, 0);
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(fetch_if.cache_hit, 0);
        bus_response.valid = 1;
        bus_response.addr = 'h0;
        bus_response.data = `LINE_WIDTH'hFFEEDDCCFFEEDDCCFFEEDDCCFFEEDDCC;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        `ASSERT_EQUAL(fetch_if.cache_hit, 0);
        #10
        bus_response.valid = 0;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(fetch_if.cache_hit, 1);
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(fetch_if.cache_hit, 1);
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(fetch_if.cache_hit, 1);
        `ASSERT_EQUAL(fetch_if.instr, 'hffeeddcc);
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(fetch_if.cache_hit, 1);
        `ASSERT_EQUAL(fetch_if.instr, 'hffeeddcc);
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(fetch_if.cache_hit, 1);
        `ASSERT_EQUAL(fetch_if.instr, 'hffeeddcc);
        // TLB test
        fetch_if.tlb_enable = 1;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(fetch_if.cache_hit, 0);
        `ASSERT_EQUAL(fetch_if.tlb_hit, 0);
        //fetch_if.pc = 'h10;
        fetch_if.tlb_write = 1;
        fetch_if.tlb_addr = 'h4;
        fetch_if.tlb_data = 'h0;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        //`ASSERT_EQUAL(fetch_if.tlb_hit, 0);
        `ASSERT_EQUAL(fetch_if.cache_hit, 0);
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(fetch_if.cache_hit, 0);
        `ASSERT_EQUAL(fetch_if.tlb_hit, 0);
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(fetch_if.cache_hit, 1);
        `ASSERT_EQUAL(fetch_if.instr, 'h11226655);
        `SUCCESS;
    end

endmodule
