`include "CPU_define.vh"
`include "CPU_types.vh"
`include "cache/CPU_cache.sv"
`include "cache/CPU_tlb.sv"
`include "core/interfaces/CPU_commit_if"
`include "cache/interfaces/CPU_mem_bus_request_if"
`include "cache/interfaces/CPU_mem_bus_response_if"

module CPU_commit #(
    parameter ADDR_WIDTH = `VIRTUAL_ADDR_WIDTH,
    parameter MEM_ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH,
    parameter DATA_WIDTH = `REG_WIDTH
)
(
    input wire clock,
    input wire reset,

    // input
    CPU_commit_if.request commit_request,
    input logic mem_bus_available,
    CPU_mem_bus_response_if.slave mem_bus_response,
    // output

    CPU_mem_bus_request_if.master mem_bus_request,
    CPU_commit_if.response commit_response
);

    logic [MEM_ADDR_WIDTH-1:0] _tlb_out;
    logic _tlb_hit;

    CPU_cache_request_if    cache_request();
    CPU_cache_response_if   cache_response();

    CPU_tlb #(
        .SIZE(`NUM_TLB_ENTRIES),
        .KEY_WIDTH(ADDR_WIDTH),
        .VALUE_WIDTH(MEM_ADDR_WIDTH)
    ) tlb (
        .clock(clock),
        .reset(reset),
        .key(commit_request.tlb_addr),
        .value(commit_request.tlb_data), 
        .write(commit_request.tlb_write),
        .out(_tlb_out)
    );

    assign _tlb_hit = _tlb_out == cache_response.addr;

    assign cache_request.read = commit_request.cache_read && (_tlb_hit || ~commit_request.tlb_enable);
    assign cache_request.write = commit_request.cache_write && (_tlb_hit || ~commit_request.tlb_enable);
    assign cache_request.mode = commit_request.cache_mode;
    assign cache_request.addr = commit_request.cache_addr[`PHYSICAL_ADDR_WIDTH-1:0];
    assign cache_request.data = commit_request.cache_data_in;

    CPU_cache cache (
        .clock(clock),
        .reset(reset),
        .cache_request(cache_request),
        .cache_response(cache_response),
        .mem_bus_available(mem_bus_available),
        .mem_bus_response(mem_bus_response),
        .mem_bus_request(mem_bus_request)
    );

    assign commit_response.tlb_hit = _tlb_hit;
    assign commit_response.cache_data_out = cache_response.data;
    assign commit_response.cache_hit = cache_response.hit;

endmodule
