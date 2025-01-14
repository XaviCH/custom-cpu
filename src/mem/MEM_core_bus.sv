`include "CPU_define.vh"
`include "mem/MEM_core_request_if.sv"
`include "mem/MEM_core_response_if.sv"
`include "mem/MEM_core_bus_request_if.sv"
`include "mem/MEM_core_bus_response_if.sv"

module MEM_core_bus #
(
    parameter ADDR_WIDTH = `PHYSICAL_ADDR_WIDTH - $clog2(`LINE_WIDTH/`BYTE_WIDTH),
    parameter MEM_LATENCY = `MEM_LATENCY
)
(
    input wire clock,
    input wire reset,

    // input
    MEM_core_bus_request_if.slave bus_request,
    MEM_core_response_if.slave core_response,

    // output
    MEM_core_bus_response_if.master bus_response,
    MEM_core_request_if.master core_request
);

    typedef struct packed {
        logic id;
        logic read;
        logic write;
        logic [ADDR_WIDTH-1:0] addr;
        logic [`LINE_WIDTH-1:0] data;
    } bus_request_t;

    typedef struct packed {
        logic id;
        logic valid;
        logic [ADDR_WIDTH-1:0] addr;
        logic [`LINE_WIDTH-1:0] data;
    } bus_response_t;

    bus_request_t     _bus_request_queue   [MEM_LATENCY];
    bus_response_t    _bus_response_queue  [MEM_LATENCY];

    assign bus_response.id      = _bus_response_queue[MEM_LATENCY-1].id;
    assign bus_response.valid   = _bus_response_queue[MEM_LATENCY-1].valid;
    assign bus_response.addr    = _bus_response_queue[MEM_LATENCY-1].addr;
    assign bus_response.data    = _bus_response_queue[MEM_LATENCY-1].data;

    assign core_request.read    = _bus_request_queue[MEM_LATENCY-1].read;
    assign core_request.write   = _bus_request_queue[MEM_LATENCY-1].write;
    assign core_request.data    = _bus_request_queue[MEM_LATENCY-1].data;
    assign core_request.addr    = _bus_request_queue[MEM_LATENCY-1].addr;

    always @(posedge clock) begin
        if (reset) begin
            for(int i=0; i<MEM_LATENCY-1; ++i) begin
                _bus_request_queue[i].read <= '0;
                _bus_request_queue[i].write <= '0;
                _bus_response_queue[i].valid <= '0;
            end
        end else begin
            for(int i=0; i<MEM_LATENCY-1; ++i) begin
                _bus_request_queue[i+1] <= _bus_request_queue[i];
                _bus_response_queue[i+1] <= _bus_response_queue[i];
            end
            _bus_request_queue[0].id    <= bus_request.id;
            _bus_request_queue[0].read  <= bus_request.read;
            _bus_request_queue[0].write <= bus_request.write;
            _bus_request_queue[0].addr  <= bus_request.addr;
            _bus_request_queue[0].data  <= bus_request.data;
            
            // TODO: response probably need addr
            _bus_response_queue[0].id       <= _bus_request_queue[MEM_LATENCY-1].id;
            _bus_response_queue[0].valid    <= core_response.valid;
            _bus_response_queue[0].addr     <= core_response.addr;
            _bus_response_queue[0].data     <= core_response.data;

        end
        //$display("--- MEM_BUS ---");
        //$display("bus_req.read %h, mem_res.valid %h, bus_res.valid: %h", _bus_request_queue[0].read, core_response.valid, bus_response.valid);
        //$display("mem_res.data: %h, mem_res.addr: %h, mem_res.valid %h", core_response.data, core_response.addr, core_response.valid);
    end

endmodule
