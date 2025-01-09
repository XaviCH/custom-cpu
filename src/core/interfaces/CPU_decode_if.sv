`include "CPU_define.vh"
`include "CPU_cache_types.svh"
interface CPU_decode_if ();

    typedef enum logic[6:0] {
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
        opcode_t opcode;
        logic [4:0] dst;
        logic [4:0] src1;
        logic [4:0] src2;
        logic [9:0] _;
    } r_instr_t;

    typedef struct packed {
        opcode_t opcode;
        logic [4:0] dst;
        logic [4:0] src1;
        logic [14:0] offset;
    } m_instr_t;

    typedef struct packed {
        opcode_t opcode;
        logic [4:0] offset_high;
        logic [4:0] src1;
        logic [4:0] src2_offset_m;
        logic [9:0] offset_low;
    } b_instr_t;

    typedef union packed {
        r_instr_t r_instr;
        m_instr_t m_instr;
        b_instr_t b_instr;
    } instr_t;

    logic [`VIRTUAL_ADDR_WIDTH-1:0] next_PC;
    logic valid_instr;
    instr_t instr;
    logic nop;
    tlb_exception_t tlb_exception;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] rm0;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] rm1;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] rm2;
    logic rm4;
    
    modport master (
        output next_PC,
        output valid_instr,
        output instr,
        output nop
    );

    modport slave (
        input next_PC,
        input valid_instr,
        input instr,
        input nop,
        output rm0,
        output rm1,
        output rm4
    );

endinterface
