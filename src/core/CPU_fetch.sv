module CPU_fetch;
(
    input wire clock,
    input wire reset,

    // cache interface
    CPU_cache_request_if.master icache_request_if,
    CPU_cache_response_if.slave icache_response_if,
    
    // inputs
    CPU_fetch_if.slave fetch_if,

    // outputs
    CPU_decode_if.master decode_if,
    output wire next_PC
);

assign next_PC = fetch_if.PC + 'd4;

assign icache_request_if.addr = fetch_if.PC;

assign decode_if.valid = icache_response_if.valid;
assign decode_if.instr = icache_response_if.word;

always @(posedge clock) begin
    if (reset) begin
        fetch_if.PC <= BOOT_ADDR;
    end else begin
        decode_if.next_PC <= next_PC;
    end
end

endmodule