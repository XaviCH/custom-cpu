`include "CPU_define.vh"
`include "CPU_types.vh"
`include "cache/CPU_cache_types.svh"
`include "cache/CPU_storebuffer.sv"
`include "cache/interfaces/CPU_cache_request_if.sv"
`include "cache/interfaces/CPU_cache_response_if.sv"
`include "cache/interfaces/CPU_mem_bus_request_if.sv"
`include "cache/interfaces/CPU_mem_bus_response_if.sv"

/**
    Cache protocol write-back, line byte replacement.
*/
module CPU_cache 
#(
    parameter SIZE = `NUM_CACHE_LINES,
    parameter LINE_WIDTH = `LINE_WIDTH,
    parameter ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH
)
(
    input wire clock,
    input wire reset,

    // input
    CPU_cache_request_if.slave cache_request,
    input logic mem_bus_available,
    CPU_mem_bus_response_if.slave mem_bus_response,

    // ouput
    CPU_cache_response_if.master cache_response,
    CPU_mem_bus_request_if.master mem_bus_request
);

    localparam BYTES_IN_LINE = LINE_WIDTH / `BYTE_WIDTH;
    localparam HALFS_IN_LINE = LINE_WIDTH / `HALF_WIDTH;
    localparam WORDS_IN_LINE = LINE_WIDTH / `WORD_WIDTH;
    localparam BYTES_IN_WORD = `WORD_WIDTH / `BYTE_WIDTH;
    localparam HALFS_IN_WORD = `WORD_WIDTH / `HALF_WIDTH;

    typedef enum logic [1:0] { INVALID, VALID, REQUESTED } line_state_e;
    typedef logic [ADDR_WIDTH-1:0] addr_t; 

    typedef union {
        logic [BYTES_IN_LINE-1:0][`BYTE_WIDTH/`BYTE_WIDTH-1:0] as_bytes;
        logic [HALFS_IN_LINE-1:0][`HALF_WIDTH/`BYTE_WIDTH-1:0] as_halfs;
        logic [WORDS_IN_LINE-1:0][`WORD_WIDTH/`BYTE_WIDTH-1:0] as_words;
    } line_dirty_u;

    typedef union {
        logic [BYTES_IN_LINE-1:0][`BYTE_WIDTH-1:0] as_bytes;
        logic [HALFS_IN_LINE-1:0][`HALF_WIDTH-1:0] as_halfs;
        logic [WORDS_IN_LINE-1:0][`WORD_WIDTH-1:0] as_words;
    } line_data_u;

    // Registers

    line_state_e    _line_states    [SIZE];
    line_dirty_u    _line_dirties   [SIZE];
    addr_t          _line_addrs     [SIZE];
    line_t          _line_datas     [SIZE];

    // Helpful logic declarations

    logic [$clog2(SIZE)-1:0]            _line_idx;
    logic [$clog2(BYTES_IN_LINE)-1:0]   _line_byte_idx;
    logic [$clog2(HALFS_IN_LINE)-1:0]   _line_half_idx;
    logic [$clog2(WORDS_IN_LINE)-1:0]   _line_word_idx;

    logic [$clog2(BYTES_IN_WORD)-1:0]   _word_byte_idx;
    logic [$clog2(HALFS_IN_WORD)-1:0]   _word_half_idx;

    assign _line_idx        = cache_request.addr[WORDS_IN_LINE +: $clog2(SIZE)];
    assign _line_byte_idx   = cache_request.addr[0 +: $clog2(BYTES_IN_LINE)];
    assign _line_half_idx   = cache_request.addr[0 +: $clog2(HALFS_IN_LINE)];
    assign _line_word_idx   = cache_request.addr[0 +: $clog2(WORDS_IN_LINE)];

    assign _word_byte_idx   = cache_request.addr[0 +: $clog2(BYTES_IN_WORD)];
    assign _word_half_idx   = cache_request.addr[0 +: $clog2(HALFS_IN_WORD)];

    // Storebuffer logic

    logic _sb_operation, _sb_pop, _sb_empty, _sb_full; 
    logic [3:0] _sb_hit_bytes, _sb_hit_bytes_pop; 
    addr_t _sb_tag_pop;
    word_t _sb_data_pop, _sb_data_response;
    logic [SIZE-1:0] _sb_hit_lines;

    // write to sb is always available if the cache line is not invalid 
    assign _sb_operation = cache_request.write 
        && _line_addrs[_line_idx]  == cache_request.addr 
        && _line_states[_line_idx] != INVALID;

    // data will be always pop unless we recieve data from main memory
    assign _sb_pop = ~_sb_empty && ~mem_bus_response.valid;

    CPU_storebuffer #(
        .SIZE(`STOREBUFFER_SIZE),
        .TAG_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(`WORD_WIDTH)
    ) storebuffer (
        .clock(clock),
        .reset(reset),
        .operation(_sb_operation),
        .mode(cache_request.mode),
        .pop(_sb_pop),
        .tag_in(cache_request.addr),
        .data_in(cache_request.data),
        .tag_pop(_sb_tag_pop),
        .data_pop(_sb_data_pop),
        .hit_bytes_pop(_sb_hit_bytes_pop),
        .empty(_sb_empty),
        .full(_sb_full),
        .hit_lines(_sb_hit_lines),
        .hit_bytes(_sb_hit_bytes),
        .data_response(_sb_data_response)
    );

     
    wire _valid_byte; 
    wire _valid_half; 
    wire _valid_word;
    assign _valid_byte = _line_states[_line_idx] == VALID || (_line_states[_line_idx] == REQUESTED && &_line_dirties[_line_idx].as_bytes[_line_byte_idx]);
    assign _valid_half = _line_states[_line_idx] == VALID || (_line_states[_line_idx] == REQUESTED && &_line_dirties[_line_idx].as_halfs[_line_half_idx]);
    assign _valid_word = _line_states[_line_idx] == VALID || (_line_states[_line_idx] == REQUESTED && &_line_dirties[_line_idx].as_words[_line_word_idx]);
    
    // READ logic
    
    typedef union {
        logic [BYTES_IN_WORD-1:0] as_bytes;
        logic [BYTES_IN_WORD/2-1:0] as_halfs;
    } hit_bytes_u;

    hit_bytes_u _bank_hit_bytes = 
        BYTES_IN_WORD'(_line_states[_line_idx] == VALID) | 
        (BYTES_IN_WORD'(_line_states[_line_idx] == REQUESTED) & _line_dirties[_line_idx].as_words[_line_word_idx]);

    word_t _bank_data = _line_datas[_line_idx].as_words[_line_word_idx];

    

    hit_bytes_u _read_hit_bytes = _bank_hit_bytes | _sb_hit_bytes;
    word_t _read_data;
    for(genvar i=0; i<BYTES_IN_WORD; ++i) begin
        assign _read_data.as_bytes[i] = 
            (`BYTE_WIDTH'(_sb_hit_bytes[i]) & _sb_data_response.as_bytes[i]) | 
            (`BYTE_WIDTH'(_sb_hit_bytes[i] && _bank_hit_bytes[i]) & _bank_data.as_bytes[i]);
    end

    wire _read_hit = 
        cache_request.mode == BYTE && _read_hit_bytes.as_bytes[_word_byte_idx] || 
        cache_request.mode == HALF && &_read_hit_bytes.as_halfs[_word_half_idx] || 
        cache_request.mode == WORD && &_read_hit_bytes;

    // WRITE logic

    wire _write_hit = _line_states[_line_idx] != INVALID && (~_sb_full || _sb_pop);

    // CACHE response logic

    logic [`WORD_WIDTH-1:0] _byte_data;
    logic [`WORD_WIDTH-1:0] _half_data;
    logic [`WORD_WIDTH-1:0] _word_data;

    assign _byte_data = {{`WORD_WIDTH-`BYTE_WIDTH{'0}} , _read_data.as_bytes[_word_byte_idx]};
    assign _half_data = {{`WORD_WIDTH-`HALF_WIDTH{'0}} , _read_data.as_halfs[_word_half_idx]};
    assign _word_data = _read_data;

    assign cache_response.data = 
        _byte_data & `WORD_WIDTH'(cache_request.mode == BYTE) |
        _half_data & `WORD_WIDTH'(cache_request.mode == HALF) |
        _word_data & `WORD_WIDTH'(cache_request.mode == WORD);

    assign cache_response.hit = 
        _read_hit  && cache_request.read ||
        _write_hit && cache_request.write;

    // MEM request
        
    assign mem_bus_request.addr = cache_request.addr[ADDR_WIDTH-1:$clog2(BYTES_IN_LINE)];
    assign mem_bus_request.read = 
        mem_bus_available && 
        cache_request.read &&
        ~_read_hit &&
        (
            _line_states[_line_idx] == INVALID ||
            _line_states[_line_idx] == VALID && ~&_line_dirties[_line_idx] && ~_sb_hit_lines[_line_idx]
        );
    assign mem_bus_request.write =
        mem_bus_available &&
        cache_request.read &&
        ~_read_hit &&
        (
            _line_states[_line_idx] == VALID && &_line_dirties[_line_idx] && ~_sb_hit_lines[_line_idx]
        );
    assign mem_bus_request.data = _line_datas[_line_idx];

    // Registers logic

    logic [$clog2(SIZE)-1:0] _mem_line_idx = mem_bus_response.addr[0 +: $clog2(SIZE)];

    always @(posedge clock) begin
        if (reset) begin
            for (int i=0; i < SIZE; ++i) begin
                _line_states  [i] <= INVALID;
                _line_dirties [i] <= '0;
            end
        end else begin
            if (mem_bus_response.valid && cache_request.write && _mem_line_idx == _line_idx) begin
                $error("Not supported write and flush to the same lane.");
            end

            if (mem_bus_response.valid) begin
                if (_line_states[_mem_line_idx] == INVALID) begin
                    _line_datas[_mem_line_idx] <= mem_bus_response.data;
                end else if (_line_states[_mem_line_idx] == INVALID) begin
                    for(int i=0; i<BYTES_IN_LINE; ++i) begin
                        if (_line_dirties[_mem_line_idx].as_bytes[i]) begin
                            _line_datas[_mem_line_idx].as_bytes[i] <= mem_bus_response.data.as_bytes[i];
                        end
                    end
                end else begin
                    $error("Unexpected behaviour, data no requested given.");
                end
                _line_addrs[_mem_line_idx] <= {mem_bus_response.addr, {$clog2(BYTES_IN_LINE){1'b0}}};
                _line_dirties[_mem_line_idx] <= '0;
                _line_states[_mem_line_idx] <= VALID;
            end

            if (_sb_pop) begin
                for(int i=0; i<BYTES_IN_WORD; ++i) begin
                    if (_sb_hit_bytes_pop[i]) begin
                        _line_dirties[_sb_tag_pop[4 +: $clog2(SIZE)]].as_words[_sb_tag_pop[3:2]][i] <= 1;
                        _line_datas  [_sb_tag_pop[4 +: $clog2(SIZE)]].as_words[_sb_tag_pop[3:2]].as_bytes[i] <= _sb_data_pop.as_bytes[i];
                    end
                end
            end

        end
    end

endmodule
