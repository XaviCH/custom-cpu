`include "CPU_define.vh"
`include "bank_reg/CPU_bank_reg_if.sv"
`include "hazard_det_unit/CPU_HDUnit_if.sv"

module CPU_mul_unit
(
    input wire clock,
    input wire reset,
    
    CPU_bank_reg_if.master_write bank_reg,
    CPU_HDUnit_if.master_mul HDUnit_if,
    CPU_mul_unit_if.slave mul_unit_if
);



endmodule