`include "CPU_define.vh"

module MEM_core 
(
    input wire clock,
    input wire reset,

    // input
    MEM_core_request_if.slave core_request_if,

    // output
    MEM_core_response_if.master core_response_if
);
    localparam NUM_LINES = `MEM_SIZE / (`LINE_WIDTH / 8);

    logic [NUM_LINES-1:0] valid_lines;
    logic [`LINE_WIDTH-1:0] mem_lines [NUM_LINES];

    always @(posedge clock) begin
        if (reset) begin
            for(int i=0; i<NUM_LINES; ++i) begin
                valid_lines[i] <= '0;
            end
        end else begin
            if (core_request_if.read) begin
                core_response_if.valid <= valid_lines[core_request_if.line_addr];
                core_response_if.line_data <= mem_lines[core_request_if.line_addr];
            end else if (core_request_if.write) begin
                core_response_if.valid <= '0;
                valid_lines[core_request_if.line_addr] <= '1;
                mem_lines[core_request_if.line_addr] <= core_request_if.line_data;
                
            end
        end
    end

endmodule
