`include "CPU_define.vh"
`include "CPU_types.vh"

typedef enum logic [0:0] { DECR=0, INCR=1 } MOD_decoded_counter_operation_e;

module MOD_decoded_counter #(
    parameter SIZE = 1
)
(
    input wire clock,
    input wire reset,

    input wire update,
    input MOD_decoded_counter_operation_e operation,
    
    output wire [SIZE-1:0] out
);

    logic [SIZE-1:0] _array;

    assign out = _array;

    always @(posedge clock) begin
        if (reset) begin
            _array[0] <= 1;
            for (int i=1; i<SIZE; ++i) begin
                _array[i] <= 0;
            end
        end else begin
            if (update) begin
                if (operation == DECR) begin
                    for(int i=0; i<SIZE-1; ++i) begin
                        _array[i] <= _array[i+1];
                    end
                    _array[SIZE-1] <= 0;
                end else begin
                    for(int i=0; i<SIZE-1; ++i) begin
                        _array[i+1] <= _array[i];
                    end
                    _array[0] <= 0;
                end
            end
        end
    end

endmodule
