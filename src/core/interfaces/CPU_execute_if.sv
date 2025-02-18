`ifndef CPU_EXECUTE_IF_SV
`define CPU_EXECUTE_IF_SV

`include "CPU_define.vh"
`include "CPU_types.vh"

interface CPU_execute_if ();

    typedef struct packed {
        logic [$clog2(`NUM_ALU_OPS)-1:0] alu_op;
        logic use_reg_b;
    } execute_t;

    typedef struct packed {
        // logic mem_to_reg;
        logic reg_write;
    } writeback_t;

    writeback_t writeback;
    CPU_commit_request_t commit;
    execute_t execute;

    // logic [`VIRTUAL_ADDR_WIDTH-1:0] next_PC;
    logic [`REG_WIDTH-1:0] ra_data;
    logic [`REG_WIDTH-1:0] rb_data;
    logic [`REG_WIDTH-1:0] offset_data;

    //TYPE_M y TYPE_R
    logic [$clog2(`NUM_REGS)-1:0] ra_id;
    logic [$clog2(`NUM_REGS)-1:0] rb_id;
    logic [$clog2(`NUM_REGS)-1:0] reg_dest;

    logic imm;


    modport master (
        output writeback,
        output commit,
        output execute,
        // output next_PC,
        output ra_data,
        output rb_data,
        output offset_data,
        output reg_dest,
        output ra_id,
        output rb_id, imm
    );

    modport slave (
        input writeback,
        input commit,
        input execute,
        // input next_PC,
        input ra_data,
        input rb_data,
        input offset_data,
        input reg_dest,
        input ra_id,
        input rb_id, imm
    );

endinterface

`endif
