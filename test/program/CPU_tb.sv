`include "core/CPU_core.sv"
`include "mem/MEM_core.sv"
`include "mem/MEM_core_bus.sv"
`include "test/CPU_define.svh"
`include "test/program/CPU_instr.sv"

module CPU_tb ();
    localparam int NUM_CODES = 2;
    localparam int CODE_ADDRS[NUM_CODES] = {0, 2};
    localparam int CODE_START_INSTR[NUM_CODES] = {0, 4};
    localparam int TOTAL_INSTR = 8;
    localparam [`INSTR_WIDTH-1:0] CODE_INSTR_DATAS[TOTAL_INSTR] = {
        I_ADD(0,1,2),
        I_ADD(0,1,2),
        I_ADD(0,1,2),
        I_ADD(0,1,2),
        I_ADD(0,1,2),
        I_ADD(0,1,2),
        I_ADD(0,1,2),
        I_STOP()
    };

    reg clock;
    reg reset;
    reg offload;

    MEM_core_bus_request_if bus_request();
    MEM_core_bus_response_if bus_response();

    MEM_core_request_if core_request();
    MEM_core_response_if core_response();

    MEM_core #(
        .NUM_CODES(NUM_CODES),
        .CODE_ADDRS(CODE_ADDRS),
        .CODE_START_INSTR(CODE_START_INSTR),
        .TOTAL_INSTR(TOTAL_INSTR),
        .CODE_INSTR_DATAS(CODE_INSTR_DATAS)
    ) memory_core (
        .clock (clock),
        .reset (reset),
        .core_request (core_request),
        .core_response (core_response)
    );

    MEM_core_bus memory_bus(
        .clock (clock),
        .reset (reset),
        .bus_request (bus_request),
        .core_request (core_request),
        .bus_response (bus_response),
        .core_response (core_response)
    );

    CPU_core core (
        .clock (clock),
        .reset (reset),
        .mem_bus_request(bus_request),
        .mem_bus_response(bus_response),
        .offload(offload)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;
    end

    always @(offload & ~reset) begin
        $display("End Of The Program.");
        $finish();
    end

endmodule
