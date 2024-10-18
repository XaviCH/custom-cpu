`include "CPU_define.vh"

module MEM_core;
(
    input wire clock;
    input wire reset;

    // input
    MEM_core_request_if.slave core_request_if,

    // output
    MEM_core_response_if.master core_response_if
);
    localparam NUM_LINES = MEM_SIZE / LINE_WIDTH;

    logic [$clog2(NUM_LINES)] memory [LINE_WIDTH];

    always @(posedge clock) begin
        if (reset) begin
            memory <= 0;
        end else begin
            if (core_request_if.read) begin
                core_response_if.valid <= '1;
                core_response_if.line_data <= memory[core_request_if.line_addr];
            end else if (core_request_if.write) begin
                core_response_if.valid <= '0;
                memory[core_request_if.line_addr] <= core_request_if.line_data;
                
            end
        end
    end

endmodule