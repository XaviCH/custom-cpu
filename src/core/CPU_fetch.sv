`include "CPU_define.vh"

module CPU_fetch
(
    input wire clock,
    input wire reset,

    // cache interface
    // CPU_cache_request_if.master icache_request_if,
    // CPU_cache_response_if.slave icache_response_if,
    
    // inputs
    CPU_commit_if.slave commit_if,
    // outputs
    CPU_decode_if.master decode_if
);

logic [`VIRTUAL_ADDR_WIDTH-1:0] PC  = `BOOT_ADDR;
wire [`VIRTUAL_ADDR_WIDTH-1:0] next_PC;

assign next_PC = ((commit_if.commit.branch && commit_if.zero) ? commit_if.branch_result : PC + 'd4);

// assign icache_request_if.addr = fetch_if.PC;

// assign decode_if.valid = icache_response_if.valid;
// assign decode_if.instr = icache_response_if.word;


always @(posedge clock) begin
    if (reset) begin
        PC <= `BOOT_ADDR;
    end else begin
        //PC CACHE LOGIC
        decode_if.next_PC <= PC+'d4;
        PC <= next_PC;
    end
end

endmodule