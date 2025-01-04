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
    logic [VIRTUAL_ADDR_WIDTH] add_result;
    logic [REG_WIDTH] alu_result;
    logic zero;
    logic [REG_WIDTH] rb;
    //TYPE_M y TYPE_R
    logic [$clog2(NUM_REGS)] reg_dest;

    modport master (
        output wb;
        output m;
        output add_result;
        output alu_result;
        output zero;
        output rb;
    );

    modport slave (
        input wb;
        input m;
        input add_result;
        input alu_result;
        input zero;
        input rb;
    );

endinterface