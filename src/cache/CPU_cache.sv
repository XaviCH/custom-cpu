module CPU_cache;
#(
    parameter NUM_LINES = 4,
    parameter ADDR_WIDTH = 32,
    parameter WORD_WIDTH = 32,
    parameter WORDS_PER_LINE = 4,
)
(
    input wire clock,
    input wire reset,

    // input
    CPU_cache_request_if.slave cache_request_if,

    // ouput
    CPU_cache_response_if.master cache_response_if
);

    reg awaiting;
    reg [NUM_LINES] valid;
    reg [NUM_LINES] addrs [ADDR_WIDTH];
    reg [NUM_LINES] lines [WORDS_PER_LINE][WORD_WIDTH];

    always @(posedge clock) begin
        if (reset) begin
            awaiting <= '0;
            valid <= '0;
        end else begin
            if (awaiting) begin
                assign cache_response_if.valid = 0;
                // TODO: Check if main memory response
            end else if(
                valid[cache_request_if.addr.line]   == 1 && 
                addr[cache_request_if.addr.line]    == cache_request_if.addr
                ) begin
                assign cache_response_if.valid = 1;
                assign cache_response_if.word = lines[cache_request_if.addr.line][cache_request_if.addr.word];
            end else begin
                // TODO: Request data to main memory
                awaiting <= 1;
                assign cache_response_if.valid = 0;
            end
        end
    end

endmodule