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
    input wire clock,
    input wire reset,

    // input
    CPU_commit_if.slave commit,
    CPU_mem_bus_response_if.slave mem_bus_in,
    // output

    CPU_mem_bus_request_if.master mem_bus_out,
    output wire tlb_hit,
    output wire [DATA_WITH-1:0] data,
    output wire cache_hit
);

wire [MEM_ADDR_WIDTH-1:0] _tlb_out;
wire _tlb_hit;
wire _write_cache;
wire _request;
wire [MEM_ADDR_WIDTH-1:0] _addr;

CPU_tlb #(
    .SIZE(`NUM_TLB_ENTRIES),
    .KEY_WIDTH(ADDR_WIDTH),
    .DATA_WITH(MEM_ADDR_WIDTH)
) tlb (
    .clock(clock),
    .reset(reset),
    .key(commit.addr),
    .value(commit.data), 
    .write(commit.write_tlb),
    .out(_tlb_out),
    .hit(_tlb_hit)
);

assign tlb_hit = _tlb_hit;
assign _write_cache = commit.write_cache && (tlb_hit && commit.tlb_enable);
assign _addr = (_tlb_out & MEM_ADDR_WIDTH'(commit.tlb_enable)) | (commit.addr & MEM_ADDR_WIDTH'(~commit.tlb_enable));

CPU_cache #(
    .ADDR_WIDTH(`PHYSICAL_ADDR_WIDTH),
    .DATA_WIDTH(MEM_ADDR_WIDTH)
) cache (
    .clock(clock),
    .reset(reset),
    .read(commit.read_cache),
    .write(_write_cache),
    .mode(commit.mode),
    .addr(_addr),
    .data(data),
    .hit(cache_hit),

    .mem_bus_available(1),
    .mem_bus_response(mem_bus_response),
    .mem_bus_request(mem_bus_request),
);

endmodule
