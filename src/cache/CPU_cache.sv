`include "CPU_define.vh"
`include "CPU_types.vh"

/**
    Cache protocol write-back, line byte replacement.
*/
module CPU_cache
(
    input wire clock,
    input wire reset,

    // input
    wire CPU_cache_request_if.slave cache_request_if,
    CPU_cache_mem_response_if.slave mem_response_if,

    // ouput
    wire CPU_cache_response_if.master cache_response_if,
    CPU_cache_mem_request_if.master mem_request_if
);

    localparam BYTES_IN_LINE = `LINE_WIDTH / `BYTE_WIDTH;
    localparam HALFS_IN_LINE = `LINE_WIDTH / `HALF_WIDTH;
    localparam WORDS_IN_LINE = `LINE_WIDTH / `WORD_WIDTH;

    typedef enum logic [2] {
        INVALID, VALID, REQUESTED
    } state_t;

    typedef union logic [BYTES_IN_LINE] {
        [BYTES_IN_LINE-1:0][BYTE_WIDTH/BYTE_WIDTH] _byte;
        [HALFS_IN_LINE-1:0][HALF_WIDTH/BYTE_WIDTH] half;
        [WORDS_IN_LINE-1:0][WORD_WIDTH/BYTE_WIDTH] word;
    } dirty_t;

    typedef logic [`VIRTUAL_ADDR_WIDTH-BYTES_IN_LINE-1:0] addr_t; 

    state_t     states      [`NUM_CACHE_LINES];
    dirty_t     dirties     [`NUM_CACHE_LINES];
    addr_t      addrs       [`NUM_CACHE_LINES];
    line_t      lines       [`NUM_CACHE_LINES];

    wire [$clog2(`NUM_CACHE_LINES)-1:0] mem_response_line = mem_response_if.addr[3:2];

    always @(posedge clock) begin
        if (reset) begin
            for (int i=0; i < `NUM_CACHE_LINES; ++i) begin
                states  [i] <= INVALID;
                dirties [i] <= '0;
            end
        end else begin
            /*
                Response from main memory behaviour.
            */
            if (mem_response_if.valid == '1) begin
                if (states[mem_response_line] == REQUESTED) begin
                    states[mem_response_line] <= VALID;
                    for(int _byte=0; _byte<BYTES_IN_LINE; ++_byte) begin
                        if (~dirties[mem_response_line]._byte[_byte] &&
                            ~(cache_request_if.write && 
                                (cache_request_if.op == WORD &&
                                    cache_request_if.addr[3:2] == _byte/4;
                                ) ||
                                (cache_request_if.op == HALF &&
                                    cache_request_if.addr[3:1] == _byte/2;
                                ) ||
                                (cache_request_if.op == BYTE &&
                                    cache_request_if.addr[3:0] == _byte/2;
                                ) 
                            )
                        ) begin
                            lines[mem_response_line]._byte[_byte] <= mem_response_if.data[(_byte+1)*BYTE_WIDTH-1:_byte*BYTE_WIDTH];
                        end
                    end
                end else begin
                    $error("Reciving not requested data.")
                end
            end 
            /*
                Check if main memory request is necesary.
            */
            if (cache_request_if.read || cache_request_if.write) begin
                if (states[cache_request_if.addr.line] == INVALID) begin
                    mem_request_if.read <= '1;  
                    mem_request_if.write <= '0; 
                    mem_request_if.addr <= cache_request_if.addr[`VIRTUAL_ADDR_WIDTH-1:BYTES_IN_LINE]; 
                    states[cache_request_if.addr.line] <= REQUESTED;
                    addrs[cache_request_if.addr.line] <= cache_request_if.addr[`VIRTUAL_ADDR_WIDTH-1:BYTES_IN_LINE];
                end else if (states[cache_request_if.addr.line] == VALID) begin
                    if (addrs[cache_request_if.addr.line] != cache_request_if.addr[`VIRTUAL_ADDR_WIDTH-1:BYTES_IN_LINE]) begin
                            if (dirties[cache_request_if.addr.line]) begin
                                mem_request_if.read  <= '0;  
                                mem_request_if.write <= '1;
                                mem_request_if.data  <= lines[cache_request_if.addr.line]; 
                                mem_request_if.addr  <= addr[cache_request_if.addr.line];
                                dirties[cache_request_if.addr.line] <= '0;
                            end else begin
                                mem_request_if.read  <= '1;  
                                mem_request_if.write <= '0;
                                mem_request_if.addr  <= cache_request_if.addr[`VIRTUAL_ADDR_WIDTH-1:BYTES_IN_LINE]; 
                                states[cache_request_if.addr.line] <= REQUESTED;
                                addrs[cache_request_if.addr.line] <= cache_request_if.addr[`VIRTUAL_ADDR_WIDTH-1:BYTES_IN_LINE];
                            end
                    end else begin
                        mem_request_if.read  <= '0;  
                        mem_request_if.write <= '0; 
                    end
                end else if (states[cache_request_if.addr.line] == REQUESTED) begin
                    mem_request_if.read  <= '0;  
                    mem_request_if.write <= '0; 
                end
            end
            /*
                Read data logic.
                    If addr is load into cache or 
                    is requested and is reading dirty bytes, hit.
                    Otherwise miss. 
            */
            if (cache_request_if.read) begin
                if (states[cache_request_if.addr.line] == VALID && 
                        addrs[cache_request_if.addr.line] == cache_request_if.addr[`VIRTUAL_ADDR_WIDTH-1:BYTES_IN_LINE] ||
                    states[cache_request_if.addr.line] == REQUESTED &&
                        addrs[cache_request_if.addr.line] == cache_request_if.addr[`VIRTUAL_ADDR_WIDTH-1:BYTES_IN_LINE] &&
                        (
                            cache_request_if.op == BYTE && dirties[cache_request_if.addr.line]._byte[cache_request_if.addr[BYTES_IN_LINE-1:0]] ||
                            cache_request_if.op == HALF && dirties[cache_request_if.addr.line].half[cache_request_if.addr[HALFS_IN_LINE-1:0]] ||
                            cache_request_if.op == WORD && dirties[cache_request_if.addr.line].word[cache_request_if.addr[WORDS_IN_LINE-1:0]] ||
                        )
                ) begin 
                    if (cache_request_if.op == WORD) begin
                        for(int word=0; word<WORDS_IN_LINE; ++word) begin
                            if (cache_request_if.addr.word == word) begin
                                cache_response_if.data <= lines[cache_request_if.addr.line].word[word];
                            end
                        end
                    end else if (cache_request_if.op == HALF) begin
                        for(int half=0; half<HALFS_IN_LINE; ++half) begin
                            if (cache_request_if.addr[3:1] == half) begin
                                cache_response_if.data <= lines[cache_request_if.addr.line].half[half];
                            end
                        end 
                    end else if (cache_request_if.op == BYTE) begin
                        for(int _byte=0; _byte<BYTES_IN_LINE; ++_byte) begin
                            if (cache_request_if.addr[3:0] == _byte) begin
                                cache_response_if.data <= lines[cache_request_if.addr.line]._byte[_byte];
                            end
                        end
                    end
                    cache_response_if.hit <= '1;
                end else begin
                    cache_response_if.hit <= '0;
                end
            /*
                Write data logic.
                    If other addrs is load and dirty miss.
                    Otherwise hits. 
            */
            end else if (cache_request_if.write) begin
                
                if (states[cache_request_if.addr.line] == INVALID ||
                    addrs[cache_request_if.addr.line] == cache_request_if.addr[`VIRTUAL_ADDR_WIDTH-1:BYTES_IN_LINE]
                ) begin
                    if (cache_request_if.op == WORD) begin
                        for(int word=0; word<WORDS_IN_LINE; ++word) begin
                            if (cache_request_if.addr.word == word) begin
                                lines   [cache_request_if.addr.line].word[word] <= cache_request_if.data;
                                dirties [cache_request_if.addr.line].word[word] <= (`WORD_WIDTH/`BYTE_WIDTH)'b1;
                            end
                        end
                    end else if (cache_request_if.op == HALF) begin
                        for(int half=0; half<HALFS_IN_LINE; ++half) begin
                            if (cache_request_if.addr[3:1] == half) begin
                                lines   [cache_request_if.addr.line].half[half] <= cache_request_if.data[`HALF_WIDTH-1:0];
                                dirties [cache_request_if.addr.line].half[half] <= (`HALF_WIDTH/`BYTE_WIDTH)'b1;
                            end
                        end 
                    end else if (cache_request_if.op == BYTE) begin
                        for(int _byte=0; _byte<BYTES_IN_LINE; ++_byte) begin
                            if (cache_request_if.addr[3:0] == _byte) begin
                                lines   [cache_request_if.addr.line]._byte[_byte] <= cache_request_if.data[`BYTE_WIDTH-1:0];
                                dirties [cache_request_if.addr.line]._byte[_byte] <= (`BYTE_WIDTH/`BYTE_WIDTH)'b1;
                            end
                        end
                    end
                    cache_response_if.hit <= '1;
                end else begin
                    cache_response_if.hit <= '0;
                end
            end
        end
    end

endmodule
