`include "CPU_define.vh"

module CPU_cache_tb ();
    
    reg clock;
    reg reset;

    CPU_cache_request_if cache_request_if();
    CPU_cache_response_if cache_response_if();
    CPU_cache_mem_request_if mem_request_if();
    CPU_cache_mem_response_if mem_response_if();

    CPU_cache cache(
        .clock (clock),
        .reset (reset),
        .cache_request_if (cache_request_if),
        .cache_response_if (cache_response_if),
        .mem_request_if (mem_request_if),
        .mem_response_if (mem_response_if)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        mem_response_if.valid = 0;
        #20 // let reset a full cicle
        reset = 0;
        cache_request_if.read = '1;
        cache_request_if.write = '0;
        cache_request_if.data = 'x;
        cache_request_if.addr = 'h0;
        $display("mem request. read: %b, write: %b, addr: %h", mem_request_if.read, mem_request_if.write, mem_request_if.addr);
        $display("cache response. valid: %b, data: %h", cache_response_if.hit, cache_response_if.data);
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
