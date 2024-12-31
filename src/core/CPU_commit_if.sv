`include "CPU_define.vh"

interface CPU_commit_if ();

    typedef struct packed {
        logic branch;
        logic mem_write;
        logic mem_read;
    } commit_t;

    typedef struct packed {
        logic mem_to_reg;
        logic reg_write;
    } writeback_t;

    commit_t commit;
    writeback_t writeback;
    logic [`REG_WIDTH-1:0] alu_result;
    logic [`REG_WIDTH-1:0] rb_data;
    //TYPE_M y TYPE_R
    logic [$clog2(`NUM_REGS)-1:0] reg_dest;

    //BRANCH
    logic [`REG_WIDTH-1:0] branch_result;
    logic zero;

    modport master (
        output commit,
        output writeback,
        output alu_result,
        output zero,
        output rb_data,
        output reg_dest,
        output branch_result
    );

    modport slave (
        input commit,
        input writeback,
        input alu_result,
        input zero,
        input rb_data,
        input reg_dest,
        input branch_result
    );

endinterface