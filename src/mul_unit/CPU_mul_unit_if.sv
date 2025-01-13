`ifndef CPU_MUL_UNIT_IF_SV
`define CPU_MUL_UNIT_IF_SV

`include "CPU_define.vh"

interface CPU_mul_unit_if ();


    
    modport master_decode(
        output writeback_mul
    );

    modport master_execute(
        output rd_id,
        output ra_data,
        output rb_data
    );
    modport slave (
        input rd_id,
        input ra_data,
        input rb_data,
        inout mul_stages,
        input writeback_mul
    );

endinterface

`endif
