`include "CPU_define.vh"

interface CPU_FWUnit_output_if ();

    wire ra_from_commit;
    wire ra_from_wb;
    wire rb_from_commit;
    wire rb_from_wb;

    modport master(
        input ra_from_commit,
        input ra_from_wb,
        input rb_from_commit,
        input rb_from_wb
    );

    modport slave (
        output ra_from_commit,
        output ra_from_wb,
        output rb_from_commit,
        output rb_from_wb
    );

endinterface