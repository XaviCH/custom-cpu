`include "CPU_define.vh"
`include "CPU_types.vh"
`include "cache/CPU_cache.sv"
`include "cache/CPU_tlb.sv"
`include "core/interfaces/CPU_fetch_if"
`include "cache/interfaces/CPU_mem_bus_request_if"
`include "cache/interfaces/CPU_mem_bus_response_if"

module CPU_fetch #(
    parameter ADDR_WIDTH = `VIRTUAL_ADDR_WIDTH,
    parameter MEM_ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH,
    parameter DATA_WIDTH = `REG_WIDTH
)
(
    input wire clock,
    input wire reset,

    // input
    CPU_fetch_if.request fetch_request,
    CPU_mem_bus_response_if.slave mem_bus_response,
    input logic mem_bus_available,
    // output

    CPU_fetch_if.response fetch_response,
    CPU_mem_bus_request_if.master mem_bus_request
);

    CPU_cache_request_if    cache_request();
    CPU_cache_response_if   cache_response();

    logic [MEM_ADDR_WIDTH-1:0] _tlb_out;
    logic _tlb_hit;

    CPU_tlb #(
        .SIZE(`NUM_TLB_ENTRIES),
        .KEY_WIDTH(ADDR_WIDTH),
        .VALUE_WIDTH(MEM_ADDR_WIDTH)
    ) tlb (
        .clock(clock),
        .reset(reset),
        .key(fetch_request.tlb_addr),
        .value(fetch_request.tlb_data), 
        .write(fetch_request.tlb_write),
        .hit(_tlb_hit),
        .out(_tlb_out)
    );

    assign cache_request.read = 1 && (_tlb_hit || ~fetch_request.tlb_enable);
    assign cache_request.write = 0; // Write not allowed on icache
    assign cache_request.mode = WORD; //
    assign cache_request.addr = fetch_request.pc;

    CPU_cache cache (
        .clock(clock),
        .reset(reset),
        .cache_request(cache_request),
        .cache_response(cache_response),
        .mem_bus_available(mem_bus_available),
        .mem_bus_response(mem_bus_response),
        .mem_bus_request(mem_bus_request)
    );
    
    assign fetch_response.tlb_hit = _tlb_hit && _tlb_out == cache_response.addr;
    assign fetch_response.instr = cache_response.data;
    assign fetch_response.cache_hit = cache_response.hit;

    always begin
        if (reset) begin
            fetch_response.next_pc = `BOOT_ADDR;
        end else begin
            if (fetch_request.exception) begin
                fetch_response.next_pc = `EXCEPTION_ADDR;
            end else if (fetch_request.jump) begin
                fetch_response.next_pc = fetch_request.jump_pc;
            end else begin
                fetch_response.next_pc = fetch_request.pc + 4;
            end 
        end
    end

endmodule
