`include "test/CPU_define.svh"
`include "core/CPU_commit.sv"

module CPU_commit_tb ();
    
    reg clock;
    reg reset;

    CPU_commit_if commit_if();
    logic mem_bus_available;
    CPU_mem_bus_request_if bus_request();
    CPU_mem_bus_response_if bus_response();

    CPU_commit commit(
        .clock (clock),
        .reset (reset),
        .commit_request (commit_if),
        .commit_response (commit_if),
        .mem_bus_available (mem_bus_available),
        .mem_bus_request (bus_request),
        .mem_bus_response (bus_response)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        mem_bus_available = 1;
        #20 // let reset a full cicle
        `ASSERT_EQUAL(commit_if.tlb_hit, 0);
        `ASSERT_EQUAL(commit_if.cache_hit, 0);
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        reset = 0;
        commit_if.tlb_enable = 0;
        mem_bus_available = 0;
        bus_response.valid = 0;
        commit_if.cache_read = '1;
        commit_if.cache_write = '0;
        commit_if.cache_addr = 'h0;
        commit_if.cache_mode = WORD;
        #10 // test wire, expect external component to catch
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10 // test regs, 
        `ASSERT_EQUAL(commit_if.cache_hit, 0);
        mem_bus_available = 1;
        #10 // test wire
        `ASSERT_EQUAL(bus_request.read, 1);
        `ASSERT_EQUAL(bus_request.write, 0);
        `ASSERT_EQUAL(bus_request.addr, 'h0);
        #10 // test reg
        `ASSERT_EQUAL(commit_if.cache_hit, 0);
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(commit_if.cache_hit, 0);
        commit_if.cache_read = 0;
        commit_if.cache_write = 1;
        commit_if.cache_data_in = 'h11223344;
        bus_response.valid = 1;
        bus_response.addr = 'h0;
        bus_response.data = `LINE_WIDTH'hFFEEDDCCFFEEDDCCFFEEDDCCFFEEDDCC;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(commit_if.cache_hit, 1);
        bus_response.valid = 0;
        commit_if.cache_data_in = 'h55;
        commit_if.cache_mode = BYTE;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(commit_if.cache_hit, 1);
        commit_if.cache_data_in = 'h66;
        commit_if.cache_addr = 'h1;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(commit_if.cache_hit, 1);
        commit_if.cache_read = 1;
        commit_if.cache_write = 0;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(commit_if.cache_hit, 1);
        `ASSERT_EQUAL(commit_if.cache_data_out, 'h66);
        commit_if.cache_addr = 'h0;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(commit_if.cache_hit, 1);
        `ASSERT_EQUAL(commit_if.cache_data_out, 'h55);
        commit_if.cache_mode = WORD;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(commit_if.cache_hit, 1);
        `ASSERT_EQUAL(commit_if.cache_data_out, 'h11226655);
        // TLB test
        commit_if.tlb_enable = 1;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(commit_if.cache_hit, 0);
        `ASSERT_EQUAL(commit_if.tlb_hit, 0);
        commit_if.tlb_write = 1;
        commit_if.tlb_addr = 'h1;
        commit_if.tlb_data = 'h0;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(commit_if.tlb_hit, 0);
        `ASSERT_EQUAL(commit_if.cache_hit, 0);
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(commit_if.cache_hit, 0);
        `ASSERT_EQUAL(commit_if.tlb_hit, 0);
        commit_if.cache_addr = 'h1;
        #10
        `ASSERT_EQUAL(bus_request.read, 0);
        `ASSERT_EQUAL(bus_request.write, 0);
        #10
        `ASSERT_EQUAL(commit_if.cache_hit, 1);
        `ASSERT_EQUAL(commit_if.cache_data_out, 'h11226655);
        `SUCCESS;
    end

endmodule
