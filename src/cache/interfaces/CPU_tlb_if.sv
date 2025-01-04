`include "CPU_define.vh"

interface CPU_tlb_if 
#(
    parameter KEY_WIDTH = `VIRTUAL_ADDR_WIDTH-$clog2(`PAGE_SIZE),
    parameter VALUE_WIDTH = `PHYSICAL_ADDR_WIDTH-$clog2(`PAGE_SIZE)
)
();

    typedef enum {
        READ, WRITE
    } tlb_operation_t;

    typedef logic [KEY_WIDTH-1:0] tlb_key_t; 
    typedef logic [VALUE_WIDTH-1:0] tlb_value_t; 

    tlb_key_t key,
    tlb_value_t value;
    tlb_operation_t operation;

    modport master (
        input key, value, operation
    );

    modport slave (
        input key, value, operation
    );

endinterface
