`include "CPU_define.vh"
`include "CPU_types.vh"
`include "cache/CPU_cache.sv"
`include "cache/CPU_tlb.sv"
`include "core/interfaces/CPU_commit_if.sv"
`include "cache/interfaces/CPU_mem_bus_request_if.sv"
`include "cache/interfaces/CPU_mem_bus_response_if.sv"

module CPU_commit #(
    parameter ADDR_WIDTH = `VIRTUAL_ADDR_WIDTH,
    parameter MEM_ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH,
    parameter PAGE_WIDTH = $clog2(`PAGE_SIZE)
)
(
    input logic clock,
    input logic reset,

    // input
    CPU_commit_if.request commit_request,
    input logic mem_bus_available,
    CPU_mem_bus_response_if.slave mem_bus_response,
    // output

    CPU_mem_bus_request_if.master mem_bus_request,
    CPU_commit_if.response commit_response
);

    logic [MEM_ADDR_WIDTH-1:PAGE_WIDTH] _tlb_out;
    logic _tlb_hit;

    CPU_cache_request_if    cache_request();
    CPU_cache_response_if   cache_response();

    CPU_tlb tlb (
        .clock(clock),
        .reset(reset),
        .key(commit_request.tlb_addr[ADDR_WIDTH-1:PAGE_WIDTH]),
        .value(commit_request.tlb_data[MEM_ADDR_WIDTH-1:PAGE_WIDTH]), 
        .write(commit_request.tlb_write),
        .hit(_tlb_hit),
        .out(_tlb_out)
    );

    assign cache_request.read = commit_request.cache_read && (_tlb_hit || ~commit_request.tlb_enable);
    assign cache_request.write = commit_request.cache_write && (_tlb_hit || ~commit_request.tlb_enable);
    assign cache_request.mode = commit_request.cache_mode;
    assign cache_request.addr =  {
        commit_request.tlb_enable ? _tlb_out : commit_request.cache_addr[MEM_ADDR_WIDTH-1:PAGE_WIDTH], 
        commit_request.cache_addr[PAGE_WIDTH-1:0]
        };
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

    assign commit_response.tlb_hit = _tlb_hit && _tlb_out == cache_response.addr[MEM_ADDR_WIDTH-1:PAGE_WIDTH];
    assign commit_response.cache_data_out = cache_response.data;
    assign commit_response.cache_hit = cache_response.hit;

    always @(posedge clock) begin
        if (commit_request.cache_read ) begin
            $display("--- COMMIT READ ---");
            $display("ADDR: %h, c_hit: %h, data_out: %h", commit_request.cache_addr, commit_response.cache_hit, commit_response.cache_data_out);
            $display("b_available: %h, b_req_read: %h, b_res_valid: %h", mem_bus_available, mem_bus_request.read, mem_bus_response.valid);
        end
        if (commit_request.cache_write ) begin
            $display("--- COMMIT  WRITE---");
            $display("ADDR: %h, c_hit: %h, data_out: %h", commit_request.cache_addr, commit_response.cache_hit, commit_response.cache_data_out);
            $display("b_available: %h, b_req_read: %h, b_res_valid: %h", mem_bus_available, mem_bus_request.read, mem_bus_response.valid);
        end
    end

endmodule
