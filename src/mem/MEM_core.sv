`include "CPU_define.vh"
`include "mem/MEM_core_request_if.sv"
`include "mem/MEM_core_response_if.sv"

module MEM_core #(
    parameter NUM_LINES = `MEM_SIZE / (`LINE_WIDTH /`BYTE_WIDTH)
)
(
    input wire clock,
    input wire reset,

    // input
    MEM_core_request_if.slave core_request,

    // output
    MEM_core_response_if.master core_response
);

    logic [`LINE_WIDTH-1:0] lines [NUM_LINES];

    assign core_response.valid = core_request.read;
    assign core_response.addr = core_request.addr;
    assign core_response.data = lines[core_request.addr];

    always @(posedge clock) begin
        if (~reset) begin
            if (core_request.write) begin
                lines[core_request.addr] <= core_request.data;
            end
        end
    end

endmodule
