`include "CPU_define.vh"


function logic [`INSTR_WIDTH-1:0] I_ADD(logic [4:0] dst, logic [4:0] src1, logic [4:0] src2);
    return {7'(`ISA_ADD_OP), {5'(dst)}, {5'(src1)},{5'(src2)}, {10{1'b0}}};
endfunction

function logic [`INSTR_WIDTH-1:0] I_SUB(logic [4:0] dst, logic [4:0] src1, logic [4:0] src2);
    return {7'(`ISA_SUB_OP), {5'(dst)}, {5'(src1)},{5'(src2)}, {10{1'b0}}};
endfunction

function logic [`INSTR_WIDTH-1:0] I_MUL(logic [4:0] dst, logic [4:0] src1, logic [4:0] src2);
    return {7'(`ISA_MUL_OP), {5'(dst)}, {5'(src1)},{5'(src2)}, {10{1'b0}}};
endfunction

function logic [`INSTR_WIDTH-1:0] I_LDB(logic [4:0] dst, logic [4:0] src1, logic [14:0] offset);
    return {7'(`ISA_LDB_OP), {5'(dst)}, {5'(src1)}, offset};
endfunction

function logic [`INSTR_WIDTH-1:0] I_LDW(logic [4:0] dst, logic [4:0] src1, logic [14:0] offset);
    return {7'(`ISA_LDW_OP), {5'(dst)}, {5'(src1)}, offset};
endfunction

function logic [`INSTR_WIDTH-1:0] I_LDI(logic [4:0] dst, logic [19:0] offset);
    return {7'(`ISA_LDI_OP), {5'(dst)}, offset};
endfunction

function logic [`INSTR_WIDTH-1:0] I_STB(logic [4:0] dst, logic [4:0] src1, logic [14:0] offset);
    return {7'(`ISA_STB_OP), {5'(dst)}, {5'(src1)}, offset};
endfunction

function logic [`INSTR_WIDTH-1:0] I_STW(logic [4:0] dst, logic [4:0] src1, logic [14:0] offset);
    return {7'(`ISA_STW_OP), {5'(dst)}, {5'(src1)}, offset};
endfunction

function logic [`INSTR_WIDTH-1:0] I_BEQ(logic [4:0] src1, logic [4:0] src2, logic [14:0] offset);
    return {7'(`ISA_BEQ_OP), offset[14:10], {5'(src1)}, {5'(src2)}, offset[9:0]};
endfunction

function logic [`INSTR_WIDTH-1:0] I_JUMP(logic [4:0] src1, logic [19:0] offset);
    return {7'(`ISA_JUMP_OP), offset[19:15], {5'(src1)}, offset[14:0]};
endfunction

function logic [`INSTR_WIDTH-1:0] I_STOP();
    return {7'(`ISA_STOP_OP), {25{1'b0}}};
endfunction
