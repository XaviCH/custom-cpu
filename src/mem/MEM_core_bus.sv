`include "CPU_define.vh"

module MEM_core_bus
(
    input wire clock,
    input wire reset,

    // input
    MEM_core_request_if.slave bus_request_if,
    MEM_core_response_if.slave core_response_if,

    // output
    MEM_core_response_if.master bus_response_if,
    MEM_core_request_if.master core_request_if
);

    localparam LINE_ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH - $clog2(`LINE_WIDTH/8);

    typedef struct {
        logic read;
        logic write;
        logic [LINE_ADDR_WIDTH-1:0] line_addr;
        logic [`LINE_WIDTH-1:0] line_data;
    } bus_request_t;

    typedef struct {
        logic valid;
        logic [`LINE_WIDTH-1:0] line_data;
    } bus_response_t;

    bus_request_t bus_request_queue[`MEM_LATENCY];
    bus_response_t bus_response_queue[`MEM_LATENCY];

    always @(posedge clock) begin
        if (reset) begin
            for(int i=0; i<`MEM_LATENCY; ++i) begin
                bus_request_queue[i].read <= '0;
                bus_request_queue[i].write <= '0;
                bus_response_queue[i].valid <= '0;
            end
        end else begin
            for(int i=0; i<`MEM_LATENCY-1; ++i) begin
                bus_request_queue[i+1] <= bus_request_queue[i];
                bus_response_queue[i+1] <= bus_response_queue[i];
            end
            bus_request_queue[0].read <= bus_request_if.read;
            bus_request_queue[0].write <= bus_request_if.write;
            bus_request_queue[0].line_addr <= bus_request_if.line_addr;
            bus_request_queue[0].line_data <= bus_request_if.line_data;
            
            bus_response_queue[0].valid <= core_response_if.valid;
            bus_response_queue[0].line_data <= core_response_if.line_data;

            core_request_if.read <= bus_request_queue[`MEM_LATENCY-1].read;
            core_request_if.write <= bus_request_queue[`MEM_LATENCY-1].write;
            core_request_if.line_addr <= bus_request_queue[`MEM_LATENCY-1].line_addr;
            core_request_if.line_data <= bus_request_queue[`MEM_LATENCY-1].line_data;

            bus_response_if.valid <= bus_response_queue[`MEM_LATENCY-1].valid;
            bus_response_if.line_data <= bus_response_queue[`MEM_LATENCY-1].line_data;
        end
    end

endmodule
