`include "CPU_define.vh"

module CPU_fetch
(
    input wire clock,
    input wire reset,

    // cache interface
    // CPU_cache_request_if.master icache_request_if,
    // CPU_cache_response_if.slave icache_response_if,
    
    // inputs
    CPU_fetch_if.slave fetch_if,
    CPU_HDUnit_if.master_fetch HDUnit_if,
    // outputs
    CPU_decode_if.master decode_if
);

logic [`VIRTUAL_ADDR_WIDTH-1:0] PC  = `BOOT_ADDR;

//DUMMY FOR TESTING
logic [`INSTR_WIDTH-1:0] ins_mem [`PAGE_WIDTH-1:0]; 

// assign icache_request_if.addr = fetch_if.PC;

// assign decode_if.valid = icache_response_if.valid;
// assign decode_if.instr = icache_response_if.word;


always @(posedge clock) begin
    if (reset) begin
        // PC <= `BOOT_ADDR;
        //DUMMY FOR TESTING
        PC <= 'h0;

    end else begin
        if (HDUnit_if.stall) begin
        end else begin
            decode_if.instr <= ins_mem[PC];
            decode_if.next_PC <= PC+'d4;
            PC <= fetch_if.change_PC ? fetch_if.new_PC : PC+'d4; 
            decode_if.nop <= fetch_if.change_PC;
        end
        //IM CACHE LOGIC
    end
end

endmodule