`include "CPU_define.vh"
`include "mem/MEM_core_request_if.sv"
`include "mem/MEM_core_response_if.sv"

module MEM_core #(
    parameter NUM_LINES = `MEM_SIZE / (`LINE_WIDTH /`BYTE_WIDTH),
    // inizialize data on memory
    parameter int NUM_CODES = 1,
    parameter int CODE_ADDRS[NUM_CODES] = {0},
    parameter int CODE_START_INSTR[NUM_CODES] = {1},
    parameter int TOTAL_INSTR = 1,
    parameter [`INSTR_WIDTH-1:0] CODE_INSTR_DATAS[TOTAL_INSTR] = {0}
)
(
    input wire clock,
    input wire reset,

    // input
    MEM_core_request_if.slave core_request,

    // output
    MEM_core_response_if.master core_response
);
    localparam INSTR_IN_LINE = `LINE_WIDTH/`WORD_WIDTH;


    logic [`LINE_WIDTH-1:0] lines [NUM_LINES];
    initial begin
        for(int code=0; code < NUM_CODES; ++code) begin
            int start_inst = CODE_START_INSTR[code]; 
            int end_instr = code == NUM_CODES-1 ? TOTAL_INSTR : CODE_START_INSTR[code+1];
            for(int instr=CODE_START_INSTR[code]; instr < end_instr; ++instr) begin
                int offset_instr = instr-start_inst;
                lines[CODE_ADDRS[code]+(offset_instr)/INSTR_IN_LINE][(offset_instr%INSTR_IN_LINE)*`INSTR_WIDTH +: `INSTR_WIDTH] = CODE_INSTR_DATAS[instr]; 
            end
        end
    end

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
