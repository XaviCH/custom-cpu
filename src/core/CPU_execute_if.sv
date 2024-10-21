`include "CPU_define.vh"

interface CPU_execute_if ();

    typedef struct packed {
        logic alu_op [$clog2(NUM_ALU_OPS)];
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

    logic [VIRTUAL_ADDR_WIDTH] next_PC;
    logic [REG_WIDTH] ra_data;
    logic [REG_WIDTH] rb_data;
    logic [REG_WIDTH] imm_data;

    //TYPE_M y TYPE_R
    logic [$clog2(NUM_REGS)] reg_dest;

    logic [REG_WIDTH] idle_reg;
    logic mul_wait;

    modport master (
        output wb,
        output m,
        output ex,
        output next_PC,
        output ra_data,
        output rb_data,
        output imm_data
    );

    modport slave (
        input wb,
        input m,
        input ex,
        input next_PC,
        input ra_data,
        input rb_data,
        input imm_data
    );

endinterface