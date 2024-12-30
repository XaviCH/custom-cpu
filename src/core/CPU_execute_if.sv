`include "CPU_define.vh"

interface CPU_execute_if ();

    typedef struct packed {
        logic [$clog2(`NUM_ALU_OPS)-1:0] alu_op;
        logic reg_b;
    } execute_t;

    typedef struct packed {
        logic branch;
        logic mem_write;
        logic mem_read;
    } commit_t;

    typedef struct packed {
        logic mem_to_reg;
        logic reg_write;
    } writeback_t;

    writeback_t writeback;
    commit_t commit;
    execute_t execute;

    logic [`VIRTUAL_ADDR_WIDTH-1:0] next_PC;
    logic [`REG_WIDTH-1:0] ra_data;
    logic [`REG_WIDTH-1:0] rb_data;
    logic [`REG_WIDTH-1:0] offset_data;

    //TYPE_M y TYPE_R
    logic [$clog2(`NUM_REGS)-1:0] ra_id;
    logic [$clog2(`NUM_REGS)-1:0] rb_id;
    logic [$clog2(`NUM_REGS)-1:0] reg_dest;
    logic use_reg_b;

    modport master (
        output writeback,
        output commit,
        output execute,
        output next_PC,
        output ra_data,
        output rb_data,
        output offset_data,
        output reg_dest,
        output use_reg_b,
        output ra_id,
        output rb_id
    );

    modport slave (
        input writeback,
        input commit,
        input execute,
        input next_PC,
        input ra_data,
        input rb_data,
        input offset_data,
        input reg_dest,
        input use_reg_b,
        input ra_id,
        input rb_id
    );

endinterface
