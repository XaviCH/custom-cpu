`include "CPU_define.vh"


function logic [`INSTR_WIDTH-1:0] I_ADD(logic [4:0] dst, logic [4:0] src1, logic [4:0] src2);
    return {7'(`ISA_ADD_OP), {5'(dst)}, {5'(src1)},{5'(src2)}, {10{1'b0}}};
endfunction

function logic [`INSTR_WIDTH-1:0] I_LDW(logic [4:0] dst, logic [4:0] src1, logic [14:0] offset);
    return {7'(`ISA_LDW_OP), {5'(dst)}, {5'(src1)}, offset};
endfunction

function logic [`INSTR_WIDTH-1:0] I_STW(logic [4:0] dst, logic [4:0] src1, logic [14:0] offset);
    return {7'(`ISA_STW_OP), {5'(dst)}, {5'(src1)}, offset};
endfunction

function logic [`INSTR_WIDTH-1:0] I_STOP();
    return {7'(`ISA_STOP_OP), {25{1'b0}}};
endfunction
