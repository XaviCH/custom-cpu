`ifndef CPU_CACHE_SV
`define CPU_CACHE_SV

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
    parameter ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH,
    //parameter BYTES_IN_INPUT = `WORD_WIDTH,
    parameter BYTES_IN_LINE = `LINE_WIDTH/`BYTE_WIDTH
)
(
    input logic clock,
    input logic reset,

    // input
    CPU_cache_request_if.slave cache_request,
    input logic mem_bus_available,
    CPU_mem_bus_response_if.slave mem_bus_response,

    // ouput
    CPU_cache_response_if.master cache_response,
    CPU_mem_bus_request_if.master mem_bus_request
);
    // Usefull variables
    // localparam BYTES_IN_HALF = `HALF_WIDTH/`BYTE_WIDTH;
    localparam BYTES_IN_WORD = `WORD_WIDTH / `BYTE_WIDTH;

    localparam HALFS_IN_WORD = `WORD_WIDTH / `HALF_WIDTH;

    // localparam HALFS_IN_LINE = BYTES_IN_LINE / BYTES_IN_HALF;
    localparam WORDS_IN_LINE = BYTES_IN_LINE / BYTES_IN_WORD;

    localparam DIRTIES_IN_BYTE = `BYTE_WIDTH/`BYTE_WIDTH;
    localparam DIRTIES_IN_HALF = `HALF_WIDTH/`BYTE_WIDTH;
    localparam DIRTIES_IN_WORD = `WORD_WIDTH/`BYTE_WIDTH;

    typedef enum logic [1:0] { INVALID, VALID, REQUESTED } line_state_e;

    // Registers

    line_state_e                                    _line_states    [SIZE];
    logic [BYTES_IN_LINE-1:0]                       _line_dirties   [SIZE];
    logic [ADDR_WIDTH-$clog2(BYTES_IN_LINE)-1:0]    _line_addrs     [SIZE];
    logic [BYTES_IN_LINE*`BYTE_WIDTH-1:0]           _line_datas     [SIZE];

    // Helpfull wires 

    logic [$clog2(SIZE)-1:0]            _line_idx;
    //logic [$clog2(BYTES_IN_LINE)-1:0]   _line_byte_idx;
    //logic [$clog2(HALFS_IN_LINE)-1:0]   _line_half_idx;
    logic [$clog2(WORDS_IN_LINE)-1:0]   _line_word_idx;

    logic [$clog2(BYTES_IN_WORD)-1:0]   _word_byte_idx;
    logic [$clog2(HALFS_IN_WORD)-1:0]   _word_half_idx;

    // logic _valid_byte, _valid_half, _valid_word;
    logic [$clog2(SIZE)-1:0] _mem_line_idx; 

    assign _line_idx        = cache_request.addr[$clog2(BYTES_IN_LINE) +: $clog2(SIZE)];
    //assign _line_byte_idx   = cache_request.addr[0 +: $clog2(BYTES_IN_LINE)];
    //assign _line_half_idx   = cache_request.addr[$clog2(BYTES_IN_HALF) +: $clog2(HALFS_IN_LINE)];
    assign _line_word_idx   = cache_request.addr[$clog2(BYTES_IN_WORD) +: $clog2(WORDS_IN_LINE)];

    assign _word_byte_idx   = cache_request.addr[0 +: $clog2(BYTES_IN_WORD)];
    assign _word_half_idx   = cache_request.addr[0 +: $clog2(HALFS_IN_WORD)];

    // assign _valid_byte = _line_states[_line_idx] == VALID || (_line_states[_line_idx] == REQUESTED && &_line_dirties[_line_idx][_line_byte_idx*DIRTIES_IN_BYTE +: DIRTIES_IN_BYTE]);
    // assign _valid_half = _line_states[_line_idx] == VALID || (_line_states[_line_idx] == REQUESTED && &_line_dirties[_line_idx][_line_half_idx*DIRTIES_IN_HALF +: DIRTIES_IN_HALF]);
    // assign _valid_word = _line_states[_line_idx] == VALID || (_line_states[_line_idx] == REQUESTED && &_line_dirties[_line_idx][_line_word_idx*DIRTIES_IN_WORD +: DIRTIES_IN_WORD]);
    assign _mem_line_idx = mem_bus_response.addr[0 +: $clog2(SIZE)];
    
    // Storebuffer logic
    // TODO: maybe replace it to an interface?

    logic _sb_operation, _sb_pop, _sb_empty, _sb_full; 
    logic [DIRTIES_IN_WORD-1:0] _sb_hit_bytes, _sb_hit_bytes_pop; 
    logic [`WORD_WIDTH-1:0] _sb_data_pop, _sb_data_response;
    logic [SIZE-1:0] _sb_hit_lines;
    // TODO: make it more suited
    /* verilator lint_off UNUSEDSIGNAL */
    logic [ADDR_WIDTH-1:0] _sb_tag_pop;
    /* verilator lint_on UNUSEDSIGNAL */
    assign _sb_operation = // write to sb is always available if the cache line is not invalid 
        cache_request.write && ~_sb_full &&
        _line_states[_line_idx] != INVALID &&
        _line_addrs[_line_idx]  == cache_request.addr[$clog2(BYTES_IN_LINE) +: ADDR_WIDTH-$clog2(BYTES_IN_LINE)]; 

    assign _sb_pop = // data will be always pop unless we recieve data from main memory
        ~_sb_empty && 
        ~mem_bus_response.valid;

    CPU_storebuffer storebuffer (
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

    // READ logic

    logic [DIRTIES_IN_WORD-1:0] _bank_hit_bytes;
    logic [`WORD_WIDTH-1:0] _bank_data;
    logic [BYTES_IN_WORD-1:0] _read_hit_bytes;
    logic [`WORD_WIDTH-1:0] _read_data;
    logic _read_hit; 

    assign _bank_data = _line_datas[_line_idx][_line_word_idx*`WORD_WIDTH +: `WORD_WIDTH];

    assign _bank_hit_bytes = 
        {BYTES_IN_WORD{1'(_line_states[_line_idx] == VALID)}} | 
        ({BYTES_IN_WORD{1'(_line_states[_line_idx] == REQUESTED)}} & _line_dirties[_line_idx][_line_word_idx*DIRTIES_IN_WORD +: DIRTIES_IN_WORD]);

    assign _read_hit_bytes = _bank_hit_bytes | _sb_hit_bytes;

    for(genvar i=0; i<BYTES_IN_WORD; ++i) begin : gen_read_data
        assign _read_data[i*`BYTE_WIDTH +: `BYTE_WIDTH] = 
            ({`BYTE_WIDTH{1'(_sb_hit_bytes[i])}} & _sb_data_response[i*`BYTE_WIDTH +: `BYTE_WIDTH]) | 
            ({`BYTE_WIDTH{1'(~_sb_hit_bytes[i] && _bank_hit_bytes[i])}} & _bank_data[i*`BYTE_WIDTH +: `BYTE_WIDTH]);
    end

    assign _read_hit = 
        _line_addrs[_line_idx]  == cache_request.addr[$clog2(BYTES_IN_LINE) +: ADDR_WIDTH-$clog2(BYTES_IN_LINE)]
        && (
            cache_request.mode == BYTE && _read_hit_bytes[_word_byte_idx*DIRTIES_IN_BYTE +: DIRTIES_IN_BYTE] || 
            cache_request.mode == HALF && &_read_hit_bytes[_word_half_idx*DIRTIES_IN_HALF +: DIRTIES_IN_HALF] || 
            cache_request.mode == WORD && &_read_hit_bytes
        );

    // WRITE logic

    logic _write_hit; 
    assign _write_hit = _sb_operation == PUSH; // && (~_sb_full || _sb_pop);

    // CACHE response logic

    logic [`WORD_WIDTH-1:0] _byte_data;
    logic [`WORD_WIDTH-1:0] _half_data;
    logic [`WORD_WIDTH-1:0] _word_data;

    assign _byte_data = {{`WORD_WIDTH-`BYTE_WIDTH{'0}} , _read_data[_word_byte_idx*`BYTE_WIDTH +: `BYTE_WIDTH]};
    assign _half_data = {{`WORD_WIDTH-`HALF_WIDTH{'0}} , _read_data[_word_half_idx*`HALF_WIDTH +: `HALF_WIDTH]};
    assign _word_data = _read_data;

    assign cache_response.data = 
        _byte_data & {`WORD_WIDTH{1'(cache_request.mode == BYTE)}} |
        _half_data & {`WORD_WIDTH{1'(cache_request.mode == HALF)}} |
        _word_data & {`WORD_WIDTH{1'(cache_request.mode == WORD)}};

    assign cache_response.hit = 
        _read_hit  && cache_request.read ||
        _write_hit && cache_request.write;

    // MEM request
        
    assign mem_bus_request.addr = 
        mem_bus_request.read ? 
            cache_request.addr[ADDR_WIDTH-1:$clog2(BYTES_IN_LINE)] : 
            _line_addrs[_line_idx];

    assign mem_bus_request.read = 
        mem_bus_available && 
        (
            (
                cache_request.read &&
                ~_read_hit &&
                (
                    _line_states[_line_idx] == INVALID ||
                    _line_states[_line_idx] == VALID && ~|_line_dirties[_line_idx] && ~_sb_hit_lines[_line_idx]
                ) 
            ) || (
                cache_request.write &&
                ~_write_hit &&
                (
                    _line_states[_line_idx] == INVALID ||
                    _line_states[_line_idx] == VALID && ~|_line_dirties[_line_idx] && ~_sb_hit_lines[_line_idx]
                ) 
            )
        );
    assign mem_bus_request.write =
        mem_bus_available &&
        (
            (
                cache_request.read &&
                ~_read_hit &&
                (_line_states[_line_idx] == VALID && |_line_dirties[_line_idx] && ~_sb_hit_lines[_line_idx])
            ) ||
            (
                cache_request.write &&
                ~_write_hit &&
                (_line_states[_line_idx] == VALID && |_line_dirties[_line_idx] && ~_sb_hit_lines[_line_idx])
            )
        );
    
    assign mem_bus_request.data = _line_datas[_line_idx];

    // Registers logic

    always @(posedge clock) begin
        if (reset) begin
            for (int i=0; i < SIZE; ++i) begin
                _line_states  [i] <= INVALID;
                _line_dirties [i] <= '0;
            end
        end else begin

            if (mem_bus_request.read) begin
                _line_states [_line_idx] <= REQUESTED;
                _line_addrs  [_line_idx] <= cache_request.addr[ADDR_WIDTH-1:$clog2(BYTES_IN_LINE)];
            end else if (mem_bus_request.write) begin
                _line_states[_line_idx] <= INVALID;
            end

            if (mem_bus_response.valid) begin
                if (_line_states[_mem_line_idx] == REQUESTED) begin
                    for(int i=0; i<BYTES_IN_LINE; ++i) begin
                        if (_line_dirties[_mem_line_idx][i*DIRTIES_IN_BYTE +: DIRTIES_IN_BYTE] == 0) begin
                            _line_datas[_mem_line_idx][i*`BYTE_WIDTH +: `BYTE_WIDTH] <= mem_bus_response.data[i*`BYTE_WIDTH +: `BYTE_WIDTH];
                        end
                    end
                end else begin
                    $error("Unexpected behaviour, data no requested given.");
                end
                
                _line_states    [_mem_line_idx] <= VALID;
            end

            if (_sb_pop) begin
                for(int i=0; i<BYTES_IN_WORD; ++i) begin
                    if (_sb_hit_bytes_pop[i]) begin
                        _line_dirties[_sb_tag_pop[4 +: $clog2(SIZE)]][_sb_tag_pop[3:2]*DIRTIES_IN_WORD +: DIRTIES_IN_WORD][i] <= 1;
                        _line_datas  [_sb_tag_pop[4 +: $clog2(SIZE)]][_sb_tag_pop[3:2]*`WORD_WIDTH +: `WORD_WIDTH][i*`BYTE_WIDTH +: `BYTE_WIDTH] <= _sb_data_pop[i*`BYTE_WIDTH +: `BYTE_WIDTH];
                    end
                end
            end

        end
    end

    always @(posedge clock) begin
        // if (_sb_operation == PUSH) begin
        //     $display("SB push");
        //     $display("mode: %h, addr: %h, data: %h", cache_request.mode, cache_request.addr, cache_request.data);
        // end
        // if (mem_bus_request.read) begin
        //     $display("-- MEM REQUEST READ --");
        //     $display("vaddr: %h, addr: %h, data: %h", cache_request.addr,  mem_bus_request.addr, mem_bus_request.data);
        // end
        // if (mem_bus_response.valid) begin
        //     $display("-- MEM RESPONSE --");
        //     $display("addr: %h, data: %h",  mem_bus_response.addr, mem_bus_response.data);
        // end
        // if (mem_bus_request.write) begin
        //     $display("-- MEM REQUEST WRITE --");
        //     $display("addr: %h, data: %h",  mem_bus_request.addr, mem_bus_request.data);
        // end
    end

endmodule

`endif 
