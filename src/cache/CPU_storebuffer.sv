`include "CPU_define.vh"
`include "CPU_types.vh"
`include "cache/CPU_cache_types.svh"

/**
    SB FIFO, for random line assignment
*/
typedef enum logic [0:0] { REQUEST=0, PUSH=1 } CPU_storebuffer_operation_e;

module CPU_storebuffer
#(
    parameter SIZE = `STOREBUFFER_SIZE,
    parameter TAG_WIDTH = `PHYSICAL_ADDR_WIDTH,
    parameter DATA_WIDTH = `WORD_WIDTH, // TODO is width is relative to byte, just ask it as nbytes
    parameter NUM_LINES = `NUM_CACHE_LINES
)
(
    input wire clock,
    input wire reset,

    input CPU_storebuffer_operation_e operation,
    input cache_mode_e mode,
    input wire pop,
    input wire [TAG_WIDTH-1:0] tag_in,
    input logic [DATA_WIDTH-1:0] data_in,

    output wire [NUM_LINES-1:0] hit_lines,
    // Queue results
    output wire [3:0] hit_bytes_pop,
    output wire [TAG_WIDTH-1:0] tag_pop,
    output logic [DATA_WIDTH-1:0] data_pop,
    output wire empty,
    output wire full,
    // Response results
    output wire [3:0] hit_bytes,
    output logic [DATA_WIDTH-1:0] data_response
);
    localparam SIZE_WIDTH = $clog2(SIZE);
    localparam BYTES_IN_DATA = DATA_WIDTH/`BYTE_WIDTH;

    // Registers

    logic [SIZE_WIDTH:0]    _n_elem;
    logic [TAG_WIDTH-1:0]   _tags [SIZE];
    logic [BYTES_IN_DATA-1:0]             _dirty_bytes [SIZE];
    logic [DATA_WIDTH-1:0]  _datas [SIZE];
    logic                   _empty;
    logic                   _full;
    logic [NUM_LINES-1:0]   _hit_lines;
    //logic [DATA_WIDTH-1:0]  _datas_response;

    // Request logic

    logic [BYTES_IN_DATA-1:0] _cmp_hit [SIZE];
    logic [DATA_WIDTH-1:0] _data_response;

    assign hit_bytes = _cmp_hit.or();
    assign data_response = _data_response;


    always_latch begin
        for(int i=0; i<SIZE; ++i) begin
            if (tag_in[TAG_WIDTH-1:$clog2(BYTES_IN_DATA)] == _tags[i][TAG_WIDTH-1:$clog2(BYTES_IN_DATA)] && i < _n_elem) begin
                for(int j=0; j<BYTES_IN_DATA; ++j) begin
                    if (_dirty_bytes[i][j] == 1) begin
                        _data_response[j*`BYTE_WIDTH +:`BYTE_WIDTH] = _datas[i][j*`BYTE_WIDTH +:`BYTE_WIDTH];
                    end
                end
                _cmp_hit[i] = _dirty_bytes[i];
            end else begin
                _cmp_hit[i] = 0;
            end
        end
    end

    // Queue logic

    assign hit_bytes_pop = _dirty_bytes[0];
    assign tag_pop = _tags[0];
    assign data_pop = _datas[0];
    assign empty = _empty;
    assign full = _full;

    logic [TAG_WIDTH-1:0] _tag_in;
    logic [DATA_WIDTH-1:0] _data_in;
    logic [BYTES_IN_DATA-1:0] _dirty_byte;
    logic [BYTES_IN_DATA-1:0] _dirty_byte_mode; 

    assign _tag_in = {tag_in[2 +: TAG_WIDTH-2], 2'b0};
    assign _data_in = data_in << tag_in[1:0]*`BYTE_WIDTH;

    assign _dirty_byte_mode =
        4'b0001 & {4{1'(mode == BYTE)}} |
        4'b0011 & {4{1'(mode == HALF)}} |
        4'b1111 & {4{1'(mode == WORD)}};

    assign _dirty_byte = _dirty_byte_mode << tag_in[1:0];

    always @(posedge clock) begin
        if (reset) begin
            _n_elem <= 0;
            _empty <= 1;
            _full <= 0;
        end else begin
            for(int i=0; i < NUM_LINES; ++i) begin
                if (i < _n_elem) begin
                    _hit_lines[_tags[i][4 +: $clog2(NUM_LINES)]] = 1;
                end
            end
            //_datas_response <= _datas[_idx_ffm];
            if (operation == PUSH) begin
                if (~pop) begin
                    if (_n_elem == SIZE) begin
                        $error("Error, trying to push on a full queue.");
                    end
                    if (_n_elem == SIZE-1) begin
                        _full <= 1;
                    end
                    _n_elem <= _n_elem + 1;
                    _tags[_n_elem[0 +: SIZE_WIDTH]] <= _tag_in;
                    _datas[_n_elem[0 +: SIZE_WIDTH]] <= _data_in;
                    _dirty_bytes[_n_elem[0 +: SIZE_WIDTH]] <= _dirty_byte;
                end else begin
                    
                    _tags[_n_elem-1] <= _tag_in;
                    _datas[_n_elem-1] <= _data_in;
                    _dirty_bytes[_n_elem-1] <= _dirty_byte;
                end
                _empty <= 0;
            end
            if (pop) begin
                if (_n_elem == 0) begin
                    $error("Error, trying to pop an empty queue.");
                end
                if (operation != PUSH) begin
                    _n_elem <= _n_elem - 1;
                    _full <= 0;
                    if (_n_elem == 1) begin
                        _empty <= 1;
                    end                        
                end
                for (int i=0; i < SIZE-1; ++i) begin
                    _tags[i] <= _tags[i+1];
                    _datas[i] <= _datas[i+1];
                    _dirty_bytes[i] <= _dirty_bytes[i+1];
                end
            end
        end
    end

endmodule
