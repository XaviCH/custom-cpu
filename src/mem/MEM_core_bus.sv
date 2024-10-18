`include "CPU_define.vh"

module MEM_core_bus;
(
    input wire clock;
    input wire reset;

    // input
    MEM_core_request_if.slave bus_request_if,
    MEM_core_response_if.slave core_response_if,

    // output
    MEM_core_response_if.master bus_response_if 
    MEM_core_request_if.master core_request_if,
);

    MEM_core_request_if bus_request_queue[MEM_LATENCY];
    MEM_core_response_if bus_response_queue[MEM_LATENCY];

    always @(posedge clock) begin
        if (reset) begin
            bus_request_queue[0] <= 0;
            bus_response_queue[0] <= 0;
        end else begin
            for(int i=0; i<MEM_LATENCY-1; ++i) begin
                bus_request_queue[i+1] <= bus_request_queue[i];
                bus_response_queue[i+1] <= bus_response_queue[i];
            end
            bus_request_queue[0] <= bus_request_if;
            bus_response_queue[0] <= core_response_if;
            
            core_request_if <= bus_request_queue[MEM_LATENCY-1];
            bus_response_if <= bus_response_queue[MEM_LATENCY-1];
        end
    end

endmodule