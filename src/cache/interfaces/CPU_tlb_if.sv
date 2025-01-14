`include "CPU_define.vh"

typedef enum {
    READ, WRITE
} CPU_tlb_operation_t;

interface CPU_tlb_if 
#(
    parameter KEY_WIDTH = `VIRTUAL_ADDR_WIDTH-$clog2(`PAGE_SIZE),
    parameter VALUE_WIDTH = `PHYSICAL_ADDR_WIDTH-$clog2(`PAGE_SIZE)
) ();

    logic [KEY_WIDTH-1:0] key;
    logic [VALUE_WIDTH-1:0] value;
    tlb_operation_t operation;

    modport master (
        input key, value, operation
    );

    modport slave (
        input key, value, operation
    );

endinterface
