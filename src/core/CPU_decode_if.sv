`include "CPU_define.vh"

interface CPU_decode_if ();

    typedef enum logic[7] {
        ADD = 'h0,
        SUB = 'h1,
        MUL = 'h2,
        LDB = 'h10,
        LDW = 'h11,
        STB = 'h12,
        STW = 'h13,
        MOV = 'h14,
        BEQ = 'h30,
        JUMP = 'h31,
        TLBWRITE = 'h32,
        IRET = 'h33
    } opcode_t;

    typedef struct packed {
        logic [10] _;
        logic [5] src2;
        logic [5] src1;
        logic [5] dst;
        opcode_t opcode;
    } r_instr_t;

    typedef struct packed {
        logic [15] offset;
        logic [5] src1;
        logic [5] dst;
        opcode_t opcode;
    } m_instr_t;

    typedef struct packed {
        logic [10] offset_low;
        logic [5] src2_offset_m;
        logic [5] src1;
        logic [5] offset_high;
        opcode_t opcode;
    } b_instr_t;

    typedef union packed {
        r_instr_t r_instr;
        m_instr_t m_instr;
        b_instr_t b_instr;
    } instr_t;

    logic [VIRTUAL_ADDR_WIDTH] next_PC;
    logic valid_instr;
    instr_t instr;
    
    modport master (
        output next_PC,
        output valid_instr,
        output instr,
    );

    modport slave (
        input next_PC,
        input valid_instr,
        input instr,
    );

endinterface