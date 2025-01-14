`include "core/CPU_core.sv"
`include "mem/MEM_core.sv"
`include "mem/MEM_core_bus.sv"
`include "test/CPU_define.svh"
`include "test/program/CPU_instr.sv"

module CPU_buffer_sum_tb ();

    localparam int A = 'h1800;
    localparam int iterations = 16;

    localparam int NUM_CODES = 1;
    localparam int CODE_ADDRS[NUM_CODES] = {`BOOT_ADDR >> 4}; // 0x1000 > 4 0x100
    localparam int CODE_START_INSTR[NUM_CODES] = {0};
    localparam int TOTAL_INSTR = 16;
    localparam [`INSTR_WIDTH-1:0] CODE_INSTR_DATAS[TOTAL_INSTR] = {
        I_LDI(0, A[19:0]), // a
        I_LDI(1, 4), // +4
        I_LDI(2, 0), // i
        I_LDI(3, 1), // +1

        I_LDI(4, 0), // count
        I_LDI(5, iterations[19:0]), // size
        I_LDI(6, 0), // ZERO
        I_LDW(7, 0, 0), // *a   #0x1c

        I_ADD(0, 0, 1), // a + 4
        I_ADD(2, 2, 3), // i + 1
        I_ADD(4, 4, 7), // count += *a
        I_BEQ(2, 5, 1), // branch i == size

        I_JUMP(6, `BOOT_ADDR+'h1c), // jump to bucle
        I_STOP(),
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
        for(int i=0; i<iterations; ++i) begin
            memory_core.lines[(A >> 4) + i/4][`WORD_WIDTH*(i%4) +: `WORD_WIDTH] = i;
        end
        #20 // let reset a full cicle
        reset = 0;
    end

    int clock_perf_data = 0;

    always @(posedge clock) begin
        if (reset) begin
            $display("START");
        end else if (offload) begin
            #900
            $display("End Of The Program: Clocks %d.", clock_perf_data);
            $display("Register data: %d", core.bank_reg.reg_file[4]);
            $finish();
        end
    end

    always @(posedge clock) begin
        if (~reset) begin 
            clock_perf_data <= clock_perf_data + 1;
        end
        // if (clock_perf_data == 100) begin 
        //     $finish();
        // end
    end

endmodule
