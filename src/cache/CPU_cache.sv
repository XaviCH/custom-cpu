`include "CPU_define.vh"

module CPU_cache
(
    input wire clock,
    input wire reset,

    // input
    CPU_cache_request_if.slave cache_request_if,
    CPU_cache_mem_response_if.slave mem_response_if,

    // ouput
    CPU_cache_response_if.master cache_response_if,
    CPU_cache_mem_request_if.master mem_request_if
);

    logic [`NUM_CACHE_LINES-1:0]    valid;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] addrs [`NUM_CACHE_LINES];
    logic [`LINE_WIDTH-1:0]         lines [`NUM_CACHE_LINES];

    wire [$clog2(`NUM_CACHE_LINES)-1:0] mem_response_line = mem_response_if.addr[3:2];

    always @(posedge clock) begin
        if (reset) begin
            valid <= '0;
        end else begin
            if (mem_response_if.valid == '1) begin 
                valid[mem_response_line] <= 1;
                addrs[mem_response_line] <= mem_response_if.addr;
                lines[mem_response_line] <= mem_response_if.data;
            end 
            
            if (valid[cache_request_if.addr.line] == '1 && addrs[cache_request_if.addr.line][31:4] == cache_request_if.addr[31:4]) begin
                cache_response_if.valid <= '1;
                if (cache_request_if.addr.word == 'b00) begin
                    cache_response_if.data  <= lines[cache_request_if.addr.line][31:0];
                end else if (cache_request_if.addr.word == 'b01) begin
                    cache_response_if.data  <= lines[cache_request_if.addr.line][63:32];
                end else if (cache_request_if.addr.word == 'b10) begin
                    cache_response_if.data  <= lines[cache_request_if.addr.line][95:64];
                end else begin
                    cache_response_if.data  <= lines[cache_request_if.addr.line][127:96];
                end

                mem_request_if.write <= '0;
                mem_request_if.read <= '0;
            end else begin
                cache_response_if.valid <= '0;

                mem_request_if.write <= '0;
                mem_request_if.read <= '1;
                mem_request_if.addr <= cache_request_if.addr;
            end
        end
    end

endmodule
