`include "core/CPU_core.sv"
`include "mem/MEM_core.sv"
`include "mem/MEM_core_bus.sv"
`include "test/CPU_define.svh"
`include "test/program/CPU_instr.sv"

module CPU_gemm_tb ();

    localparam int A = 'h10000;
    localparam int B = 'h20000;
    localparam int C = 'h30000;
    localparam int M = 128;

    localparam int NUM_CODES = 1;
    localparam int CODE_ADDRS[NUM_CODES] = {`BOOT_ADDR >> 4}; // 0x1000 > 4 0x100
    localparam int CODE_START_INSTR[NUM_CODES] = {0};
    localparam int TOTAL_INSTR = 40;
    localparam [`INSTR_WIDTH-1:0] CODE_INSTR_DATAS[TOTAL_INSTR] = {
        I_LDI(0, A[19:0]), // const a
        I_LDI(1, B[19:0]), // const b
        I_LDI(2, C[19:0]), // const c
        I_LDI(3, 4),   // const 4
        
        I_LDI(4, {(M*4)}[19:0]), // const M*4
        I_LDI(5, {M*M*4}[19:0]), // const M*M*4
        I_LDI(6, 0),   // const ZERO
        I_LDI(7, 0), // i # + M*4

        I_LDI(8, 0), // j # + 4 0x20
        I_LDI(9, 0), // temp of c
        I_LDI(10, 0), // k_rows # + M*4
        I_LDI(11, 0), // k_cols # + 4

        I_ADD(12, 0, 7), // # 0x30
        I_ADD(12, 12, 11), // &a[i][k]
        I_LDW(12, 12, 0), // *a
        I_ADD(13, 1, 10),

        I_ADD(13, 13, 8), // &b[k][j]
        I_LDW(13, 13, 0), // *j
        I_MUL(12, 12, 13), //
        I_ADD(9, 9, 12), // temp = temp + a[][]*b[][]

        I_ADD(10, 10, 4), 
        I_ADD(11, 11, 3),
        I_BEQ(11, 4, 1), // branch j == M*4
        I_JUMP(6, `BOOT_ADDR+'h30), // jump to j

        I_ADD(12, 2, 7),
        I_ADD(12, 12, 8), // &c[i][j]
        I_STW(9, 12, 0),
        I_ADD(8, 8, 3),

        I_BEQ(8, 4, 1), // branch j == M*4
        I_JUMP(6, `BOOT_ADDR+'h24), // jump to j
        I_ADD(7, 7, 4),
        I_BEQ(7, 5, 1), // branch i == M*M*4

        I_JUMP(6, `BOOT_ADDR+'h20), // jump to i
        I_STW(0, 6, 0),
        I_STW(0, 6, 16),
        I_STW(0, 6, 32),

        I_STW(0, 6, 48),
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
        for(int i=0; i<M*M; ++i) begin
            memory_core.lines[(A >> 4) + i/4][`WORD_WIDTH*(i%4) +: `WORD_WIDTH] = 2;
        end
        for(int i=0; i<M*M; ++i) begin
            memory_core.lines[(B >> 4) + i/4][`WORD_WIDTH*(i%4) +: `WORD_WIDTH] = 2;
        end
        #20 // let reset a full cicle
        reset = 0;
    end

    int clock_perf_data = 0;

    always @(posedge clock) begin
        if (reset) begin
            $display("START");
        end else if (offload) begin
            #200
            for (int i=0; i < M; ++i) begin
                int mod = i % 4;
                `ASSERT_EQUAL(memory_core.lines[(C >> 4) + i/4][`WORD_WIDTH*mod +: `WORD_WIDTH], M*4);
            end
            $display("Performance data: total_clocks=%d.", clock_perf_data);
            `SUCCESS
        end
    end

    always @(posedge clock) begin
        if (~reset) begin 
            clock_perf_data <= clock_perf_data + 1;
        end
    end

endmodule
