`ifndef CPU_STOREBUFFER_SV
`define CPU_STOREBUFFER_SV

`include "CPU_define.vh"
`include "CPU_types.vh"
`include "cache/CPU_cache_types.svh"

/**
    SB FIFO, for direct assignment cache
*/
typedef enum logic [0:0] { REQUEST=0, PUSH=1 } CPU_storebuffer_operation_e;

module CPU_storebuffer
#(
    parameter SIZE = `STOREBUFFER_SIZE,
    parameter TAG_WIDTH = `PHYSICAL_ADDR_WIDTH,
    parameter BYTES_IN_DATA = `WORD_WIDTH/`BYTE_WIDTH,
    // thus next are for extra data for a direct map cache
    parameter NUM_LINES = `NUM_CACHE_LINES,
    parameter BYTES_IN_LINE = `LINE_WIDTH/`BYTE_WIDTH
)
(
    input logic clock,
    input logic reset,

    input CPU_storebuffer_operation_e operation,
    input cache_mode_e mode,
    input logic pop,
    input logic [TAG_WIDTH-1:0] tag_in,
    input logic [DATA_WIDTH-1:0] data_in,

    // Queue results
    output logic empty,
    output logic full,
    output logic [NUM_LINES-1:0]        hit_lines, // lines that are affected in sb
    output logic [TAG_WIDTH-1:0]        tag_pop,
    output logic [BYTES_IN_DATA-1:0]    hit_bytes_pop,
    output logic [DATA_WIDTH-1:0]       data_pop,
    // Response results
    output logic [BYTES_IN_DATA-1:0] hit_bytes,
    output logic [DATA_WIDTH-1:0] data_response
);
    localparam SIZE_WIDTH = $clog2(SIZE);
    localparam DATA_WIDTH = BYTES_IN_DATA*`BYTE_WIDTH;

    // Registers

    logic                       _empty;
    logic                       _full;
    logic [SIZE_WIDTH:0]        _n_elem;
    logic [TAG_WIDTH-1:0]       _tags           [SIZE];
    logic [BYTES_IN_DATA-1:0]   _dirty_bytes    [SIZE];
    logic [DATA_WIDTH-1:0]      _datas          [SIZE];

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

    assign empty            = _empty;
    assign full             = _full;
    assign hit_bytes_pop    = _dirty_bytes[0];
    assign tag_pop          = _tags[0];
    assign data_pop         = _datas[0];

    logic [NUM_LINES-1:0] _cmps_lines [SIZE];

    for(genvar i=0; i < SIZE; ++i) begin : gen_cmps_lines
        for (genvar j=0; j < NUM_LINES; ++j) begin : gen_cmps_lines_i
            assign _cmps_lines[i][j] = i < _n_elem && _tags[i][$clog2(BYTES_IN_LINE) +: $clog2(NUM_LINES)] == j;
        end
    end

    assign hit_lines = _cmps_lines.or();

    // Register logic

    logic [TAG_WIDTH-1:0]       _tag_in;
    logic [DATA_WIDTH-1:0]      _data_in;
    logic [BYTES_IN_DATA-1:0]   _dirty_byte;
    logic [BYTES_IN_DATA-1:0]   _dirty_byte_mode; 

    assign _tag_in = {tag_in[TAG_WIDTH-1:$clog2(BYTES_IN_DATA)], {$clog2(BYTES_IN_DATA){1'b0}}};
    assign _data_in = data_in << tag_in[$clog2(BYTES_IN_DATA)-1:0]*`BYTE_WIDTH;

    assign _dirty_byte_mode =
        4'b0001 & {4{1'(mode == BYTE)}} |
        4'b0011 & {4{1'(mode == HALF)}} |
        4'b1111 & {4{1'(mode == WORD)}};

    assign _dirty_byte = _dirty_byte_mode << tag_in[$clog2(BYTES_IN_DATA)-1:0];

    always @(posedge clock) begin
        if (reset) begin
            _empty <= 1;
            _full <= 0;
            _n_elem <= 0;
        end else begin
            if (operation == PUSH) begin
                if (~pop) begin
                    if (_n_elem == SIZE-1) begin
                        _full <= 1;
                    end
                    _n_elem <= _n_elem + 1;
                    _tags        [_n_elem[0 +: SIZE_WIDTH]] <= _tag_in;
                    _datas       [_n_elem[0 +: SIZE_WIDTH]] <= _data_in;
                    _dirty_bytes [_n_elem[0 +: SIZE_WIDTH]] <= _dirty_byte;

                    if (_n_elem == SIZE) begin // DEBUG rutine
                        $error("Error, trying to push on a full queue.");
                    end
                end else begin
                    _tags        [_n_elem-1] <= _tag_in;
                    _datas       [_n_elem-1] <= _data_in;
                    _dirty_bytes [_n_elem-1] <= _dirty_byte;
                end
                _empty <= 0;
            end else if (pop) begin
                if (_n_elem == 1) begin
                    _empty <= 1;
                end
                _n_elem <= _n_elem - 1;
                _full   <= 0;
                for (int i=0; i < SIZE-1; ++i) begin
                    _tags        [i] <= _tags[i+1];
                    _datas       [i] <= _datas[i+1];
                    _dirty_bytes [i] <= _dirty_bytes[i+1];
                end

                if (_n_elem == 0) begin // DEBUG rutine
                    $error("Error, trying to pop an empty queue.");
                end
            end
        end
    end

endmodule

`endif
