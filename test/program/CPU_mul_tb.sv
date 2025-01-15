`include "core/CPU_core.sv"
`include "mem/MEM_core.sv"
`include "mem/MEM_core_bus.sv"
`include "test/CPU_define.svh"
`include "test/program/CPU_instr.sv"

module CPU_mul_tb ();

    localparam int NUM_CODES = 1;
    localparam int CODE_ADDRS[NUM_CODES] = {`BOOT_ADDR >> 4}; // 0x1000 > 4 0x100
    localparam int CODE_START_INSTR[NUM_CODES] = {0};
    localparam int TOTAL_INSTR = 8;
    localparam [`INSTR_WIDTH-1:0] CODE_INSTR_DATAS[TOTAL_INSTR] = {
        I_LDI(0, 5), // a
        I_LDI(1, 4), // +4
        I_LDI(2, 0), // i
        I_LDI(3, 1), // +1

        I_MUL(4, 0, 1), // 5x4
        I_ADD(4, 4, 1), // 20 + 2
        I_STOP(),
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
            $display("START");
        end else if (offload) begin
            #40
            `ASSERT_EQUAL(core.bank_reg.reg_file[4], 24);
            $display("Performance data: total_clocks=%d.", clock_perf_data);
            `SUCCESS;
        end
    end

    always @(posedge clock) begin
        if (~reset) begin 
            clock_perf_data <= clock_perf_data + 1;
        end
        if (clock_perf_data == 60) begin 
            $finish();
        end
    end

endmodule
