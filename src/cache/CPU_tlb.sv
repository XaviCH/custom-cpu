`ifndef CPU_TLB_SV
`define CPU_TLB_SV

`include "CPU_define.vh"
`include "CPU_types.vh"

/**
    TLB 
    FIFO, on write do not check if entry is in the queue, UB if does.
*/
module CPU_tlb
#(
    parameter SIZE          = `NUM_TLB_ENTRIES,
    parameter KEY_WIDTH     = `VIRTUAL_ADDR_WIDTH  - $clog2(`PAGE_SIZE),
    parameter VALUE_WIDTH   = `PHYSICAL_ADDR_WIDTH - $clog2(`PAGE_SIZE)
)
(
    input logic clock,
    input logic reset,

    input logic write,
    input logic [KEY_WIDTH-1:0] key,
    input logic [VALUE_WIDTH-1:0] value, 

    output logic hit,
    output logic [VALUE_WIDTH-1:0] out
);
    // Registers

    logic                   _valids [SIZE];
    logic [KEY_WIDTH-1:0]   _keys   [SIZE];
    logic [VALUE_WIDTH-1:0] _values [SIZE];

    // READ logic

    wire [SIZE-1:0]         _cmps;
    wire [VALUE_WIDTH-1:0]  _cmps_keys [SIZE];

    for(genvar i=0; i<SIZE; ++i) begin : gen_cmps
        assign _cmps[i] = key == _keys[i] && _valids[i];
    end
    for(genvar i=0; i<SIZE; ++i) begin : gen_cmps_keys
        assign _cmps_keys[i] = _values[i] & {VALUE_WIDTH{(_cmps[i])}}; 
    end

    assign hit = |_cmps;
    assign out = _cmps_keys.or();
    
    // WRITE logic

    always @(posedge clock) begin
        if (reset) begin
            for (int i=0; i < SIZE; ++i) begin
                _valids [i] <= 0;
            end
        end else begin
            if (write) begin
                for(int i=0; i < SIZE-1; ++i) begin
                    _valids [i+1] <= _valids[i];
                    _keys   [i+1] <= _keys[i];
                    _values [i+1] <= _values[i];
                end
                _valids [0] <= 1;
                _keys   [0] <= key;
                _values [0] <= value;
            end
        end
    end

endmodule

`endif
