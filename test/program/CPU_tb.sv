`include "core/CPU_core.sv"
`include "mem/MEM_core.sv"
`include "mem/MEM_core_bus.sv"
`include "test/CPU_define.svh"
`include "test/program/CPU_instr.sv"

module CPU_tb ();

    localparam int NUM_CODES = 1;
    localparam int CODE_ADDRS[NUM_CODES] = {`BOOT_ADDR >> 4}; // 0x1000 > 4 0x100
    localparam int CODE_START_INSTR[NUM_CODES] = {0};
    localparam int TOTAL_INSTR = 8;
    localparam [`INSTR_WIDTH-1:0] CODE_INSTR_DATAS[TOTAL_INSTR] = {
        I_LDI(0, 10),
        I_ADD(1,0,0),
        I_STW(1, 2, `BOOT_ADDR),
        I_STW(0, 2, `BOOT_ADDR+64),
        I_STOP(),
        0,
        0,
        0
    };

    reg clock;
    reg reset = 1;
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

    int clock_perf_data = 0;

    always @(posedge clock) begin
        if (reset) begin
            $display("line data: %h", memory_core.lines [`BOOT_ADDR >> 4]);
        end else if (offload) begin
            #900
            $display("End Of The Program: Clocks %d.", clock_perf_data);
            $display("Out data: %h", memory_core.lines [`BOOT_ADDR >> 4]);
            $finish();
        end
    end

    always @(posedge clock) begin
        if (~reset) begin 
            clock_perf_data <= clock_perf_data + 1;
        end
    end

endmodule
