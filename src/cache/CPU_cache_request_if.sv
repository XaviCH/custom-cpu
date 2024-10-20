`include "CPU_define.vh"

interface CPU_cache_request_if ();

    typedef enum {
        WORD, BYTE
    } op_t;

    typedef struct packed {
        logic [25:0] _;
        logic [1:0] line;
        logic [1:0] word;
        logic [1:0] _byte;
    } addr_t;

    logic read, write;
    op_t op;
    logic [31:0] data;
    addr_t addr;

    modport master (
        output read, write, op, data, addr
    );

    modport slave (
        input read, write, op, data, addr
    );

endinterface
