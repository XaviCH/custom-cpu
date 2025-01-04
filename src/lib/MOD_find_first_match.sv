`include "CPU_define.vh"
`include "CPU_types.vh"

module MOD_find_first_match #(
    parameter SIZE,
    parameter DATA_WIDTH,
    parameter REVERSE = 0
) (
    input wire [DATA_WIDTH-1:0] target,
    input wire [DATA_WIDTH-1:0] data_in [SIZE],
    input wire valid_in [SIZE],

    output wire found,
    output logic [$clog2(SIZE)-1:0] idx
);
    wire [SIZE-1:0] _cmps ;
    wire [SIZE-1:0] _cmps_x_cmps ;

    for (genvar i=0; i<SIZE; ++i) begin : gen_cmps
        assign _cmps[i] = target == data_in[i] && valid_in[i];
    end

    assign _cmps_x_cmps[0] = REVERSE ? _cmps[0] && ~(|_cmps[SIZE-1:1]) : _cmps[0];
    assign _cmps_x_cmps[SIZE-1] = REVERSE ? _cmps[SIZE-1] : _cmps[SIZE-1] && ~(|_cmps[SIZE-2:0]);

    for (genvar i=1; i<SIZE-1; ++i) begin : gen_cmps_cmps
        assign _cmps_x_cmps[i] = REVERSE ? _cmps[i] && ~(|_cmps[i+1:SIZE-1]) : _cmps[i] && ~(|_cmps[0:i-1]);
    end

    always_latch begin
        for (int i=0; i<SIZE; ++i) begin
            if (_cmps_x_cmps[i]) begin
                idx = $clog2(SIZE)'(i);
            end
        end
    end

    assign found = |_cmps;

endmodule
