`include "CPU_define.vh"
`include "core/CPU_fetch.sv"
`include "core/CPU_decode.sv"
`include "core/CPU_commit.sv"
`include "core/CPU_execute.sv"
`include "bank_reg/CPU_bank_reg.sv"
`include "cache/CPU_cache_types.svh"
`include "cache/interfaces/CPU_mem_bus_request_if.sv"
`include "cache/interfaces/CPU_mem_bus_response_if.sv"
`include "forward_unit/CPU_FWUnit.sv"
`include "hazard_det_unit/CPU_HDUnit.sv"
`include "mem/MEM_core_bus_request_if.sv"
`include "mem/MEM_core_bus_response_if.sv"

module CPU_core
(
    input wire clock,
    input wire reset,

    MEM_core_bus_request_if.master mem_bus_request,
    MEM_core_bus_response_if.slave mem_bus_response,

    output wire offload 
);

    // Pipeline registers
    logic [`VIRTUAL_ADDR_WIDTH-1:0] F_pc;

    logic D_hit;
    logic [`INSTR_WIDTH-1:0] D_instr;
    tlb_exception_t D_tlb_exception;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] D_next_pc;

    logic           E_usermode, E_write, E_read;
    tlb_write_t     E_tlb_write;
    cache_mode_e    E_mode;
    tlb_exception_t E_tlb_exception;
    logic E_bank_write;
    logic [$clog2(`NUM_REGS)-1:0] E_reg_dst;
    // logic [`REG_WIDTH-1:0]   E_data;

    tlb_exception_t         C_tlb_exception;
    tlb_write_t             C_tlb_write;
    cache_mode_e            C_mode;
    logic                   C_usermode, C_write, C_read;
    logic [`REG_WIDTH-1:0]   C_data;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] C_addr;
    logic C_bank_write;
    logic [$clog2(`NUM_REGS)-1:0] C_reg_dst;
    // logic [`VIRTUAL_ADDR_WIDTH-1:0] C_addr;

    tlb_exception_t W_tlb_exception;
    logic W_write;
    logic [`REG_WIDTH-1:0] W_data;
    logic [$clog2(`NUM_REGS)-1:0] W_reg;

    logic _offload;
    assign offload = _offload;
    // Pipeline interfaces
    CPU_fetch_if fetch_if();
    CPU_decode_if decode_if();
    CPU_execute_if execute_if();
    CPU_commit_if commit_if();

    assign fetch_if.pc = F_pc;
    assign fetch_if.exception = W_tlb_exception.raise;

    assign fetch_if.tlb_enable = decode_if.rm4 != `SUPERUSER_MODE;
    assign fetch_if.tlb_addr = decode_if.tlb_write.addr;
    assign fetch_if.tlb_data = decode_if.tlb_write.data;
    assign fetch_if.tlb_write = decode_if.itlb_write;

    // assign F_usermode = decode_it.rm4; // usermode
    
    assign decode_if.valid_instr = D_hit;
    assign decode_if.instr = D_instr;
    assign decode_if.next_PC = D_next_pc;
    assign decode_if.nop = ~D_hit; // ??
    assign decode_if.tlb_exception = W_tlb_exception;

    assign E_tlb_write = decode_if.tlb_write;
    assign E_write = execute_if.commit.mem_write;
    assign E_read = execute_if.commit.mem_read;
    assign E_mode = execute_if.commit.mode;
    assign E_bank_write = execute_if.writeback.reg_write;
    assign E_reg_dst = execute_if.reg_dest;
    
    assign commit_if.cache_write = C_write; 
    assign commit_if.cache_read = C_read;
    assign commit_if.cache_mode = C_mode;
    assign commit_if.cache_data_in = C_data;    // commit_if.rb_data;
    assign commit_if.cache_addr = C_addr;       // commit_if.alu_result;

    assign commit_if.tlb_enable = C_usermode != `SUPERUSER_MODE;
    assign commit_if.tlb_addr = C_tlb_write.addr;
    assign commit_if.tlb_data = C_tlb_write.data;
    assign commit_if.tlb_write = C_tlb_write.enable;

    // Memory interfaces
    CPU_mem_bus_request_if icache_mem_bus_request();
    CPU_mem_bus_request_if dcache_mem_bus_request();
    CPU_mem_bus_response_if icache_mem_bus_response();
    CPU_mem_bus_response_if dcache_mem_bus_response();

    // Memory module
    always_latch begin
        // request router
        if (dcache_mem_bus_request.read || dcache_mem_bus_request.write) begin
            mem_bus_request.id      = 0;
            mem_bus_request.read    = dcache_mem_bus_request.read;
            mem_bus_request.write   = dcache_mem_bus_request.write;
            mem_bus_request.data    = dcache_mem_bus_request.data;
            mem_bus_request.addr    = dcache_mem_bus_request.addr;
        end else if (icache_mem_bus_request.read || icache_mem_bus_request.write) begin
            mem_bus_request.id      = 1;
            mem_bus_request.read    = icache_mem_bus_request.read;
            mem_bus_request.write   = icache_mem_bus_request.write;
            mem_bus_request.data    = icache_mem_bus_request.data;
            mem_bus_request.addr    = icache_mem_bus_request.addr;
        end else begin
            mem_bus_request.read    = 0;
            mem_bus_request.write   = 0;
        end
        // response router
        if (mem_bus_response.valid) begin
            if (mem_bus_response.id == 0) begin
                dcache_mem_bus_response.valid   = 1;
                dcache_mem_bus_response.addr    = mem_bus_response.addr;
                dcache_mem_bus_response.data    = mem_bus_response.data;
            end else begin
                dcache_mem_bus_response.valid = 0;
            end
            if (mem_bus_response.id == 1) begin
                icache_mem_bus_response.valid   = 1;
                icache_mem_bus_response.addr    = mem_bus_response.addr;
                icache_mem_bus_response.data    = mem_bus_response.data;
            end else begin
                icache_mem_bus_response.valid = 0;
            end
        end else begin
            dcache_mem_bus_response.valid = 0;
            icache_mem_bus_response.valid = 0;
        end
    end
    

    CPU_FWUnit_if FWUnit_if();

    assign FWUnit_if.commit_value       = C_addr;
    assign FWUnit_if.writeback_commit   = C_bank_write && ~C_read;
    assign FWUnit_if.rd_commit          = C_reg_dst;

    assign FWUnit_if.writeback_wb       = W_write;
    assign FWUnit_if.rd_wb              = W_reg;
    assign FWUnit_if.wb_value           = W_data;

    CPU_HDUnit_if HDUnit_if();
    
    assign HDUnit_if.execute_mem_read   = E_read;
    assign HDUnit_if.execute_rd         = E_reg_dst;
    assign HDUnit_if.execute_wb         = E_bank_write;

    assign HDUnit_if.commit_mem_read    = C_read;
    assign HDUnit_if.commit_rd          = C_reg_dst;

    CPU_FWUnit FWUnit
    (
        .FWUnit_if(FWUnit_if)
    );

    CPU_HDUnit HDUnit
    (
        .HDUnit_if(HDUnit_if)
    );

    // Pipeline declaration
    CPU_fetch fetch
    (
        .clock (clock),
        .reset (reset),
        .fetch_request (fetch_if),
        .fetch_response (fetch_if),
        .mem_bus_available(~dcache_mem_bus_request.read & ~dcache_mem_bus_request.write), // depends on dcache
        .mem_bus_request(icache_mem_bus_request),
        .mem_bus_response(icache_mem_bus_response)
    );

    CPU_bank_reg_if bank_reg_if();

    CPU_bank_reg bank_reg
    (
        .clock(clock),
        .reset(reset),
        .bank_reg_if(bank_reg_if),
        .FWUnit_if(FWUnit_if)
    );

    assign bank_reg_if.writeback.write_enable = W_write;
    assign bank_reg_if.writeback.write_reg = W_reg;
    assign bank_reg_if.writeback.write_data = W_data;

    CPU_decode decode
    (
        .clock (clock),
        .reset (reset),
        .bank_reg_if (bank_reg_if),
        .fetch_if (fetch_if),
        .decode_if (decode_if),
        .execute_if (execute_if),
        .FWUnit_if(FWUnit_if),
        .HDUnit_if(HDUnit_if),
        .offload(_offload)
    );

    CPU_execute execute
    (
        .clock (clock),
        .reset (reset),
        .execute_if (execute_if),
        .FWUnit_if(FWUnit_if),
        .HDUnit_if(HDUnit_if),
        .bank_reg_if (bank_reg_if),
        .commit_if (commit_if)
    );

    CPU_commit commit
    (
        .clock (clock),
        .reset (reset),
        .commit_request (commit_if),
        .commit_response (commit_if),
        .mem_bus_available (1), // Has priority over icache
        .mem_bus_request (dcache_mem_bus_request),
        .mem_bus_response (dcache_mem_bus_response)
    );

    // Registers logic
    logic required_dcache;
    logic required_dtlb;
    assign required_dcache = C_read || C_write;
    assign required_dtlb = required_dcache && commit_if.tlb_enable;

    assign HDUnit_if.cache_miss = required_dcache && ~commit_if.cache_hit;

    always @(posedge clock) begin
        if (reset) begin
            F_pc <= fetch_if.next_pc;
        end else if (~(required_dcache && ~commit_if.cache_hit)) begin // dcache miss behaviour

            if ((fetch_if.cache_hit || fetch_if.jump) && ~HDUnit_if.stall /* <-- q es esto */) begin
                F_pc <= fetch_if.next_pc;
            end

            if (~HDUnit_if.stall && ~HDUnit_if.stall_decode) begin
                D_next_pc   <= fetch_if.next_pc;
                D_instr     <= fetch_if.instr;
                D_hit       <= (~fetch_if.tlb_enable || fetch_if.tlb_hit) && fetch_if.cache_hit;

                D_tlb_exception.raise   <= ~fetch_if.tlb_hit && fetch_if.tlb_enable;
                D_tlb_exception.vaddr   <= fetch_if.tlb_addr;
                D_tlb_exception.pc      <= fetch_if.pc;
            end

            if (~HDUnit_if.stall) begin
                E_tlb_exception         <= D_tlb_exception;
                E_usermode              <= decode_if.rm4;
            end

            C_tlb_exception         <= E_tlb_exception;
            C_usermode              <= E_usermode;
            C_mode                  <= E_mode;
            C_write                 <= E_write;
            C_read                  <= E_read;
            C_tlb_write             <= E_tlb_write;
            C_addr                  <= commit_if.alu_result;
            C_data                  <= commit_if.rb_data;
            C_bank_write            <= E_bank_write;
            C_reg_dst               <= E_reg_dst;

            if (required_dtlb && ~commit_if.tlb_hit) begin
                W_tlb_exception.raise   <= 1;
                W_tlb_exception.vaddr   <= commit_if.cache_addr;
                W_tlb_exception.pc      <= C_tlb_exception.pc;
            end else begin
                W_tlb_exception <= C_tlb_exception;
            end

            W_write <= C_bank_write && (~C_read || commit_if.cache_hit);
            W_data <= C_read ? commit_if.cache_data_out : C_addr;
            W_reg <= C_reg_dst;
            
        end
    end

    always @(posedge clock) begin
        // $display("--- CORE ---");
        // $display("E: bank_write: %h, pc: %h", E_bank_write, E_tlb_exception.pc);
        // $display("C: addr: %h, data: %h cdata %h, read %h, bank_write: %h, pc %h", C_addr, C_data, commit_if.cache_data_out, C_read, C_bank_write, C_tlb_exception.pc);
        // $display("W: write: %h, data %h, reg %h, pc: %h", W_write, W_data, W_reg, W_tlb_exception.pc);
        // $display("----HDUNIT----");
        // $display("stall: %h", HDUnit_if.stall);
        // $display("rlh: %h, read: %h, rd: %h=%h, ra: %h=%h, rb: %h=%h", 
        //     HDUnit.read_load_hazard, HDUnit_if.execute_mem_read, 
        //     1/* ?? */, HDUnit_if.execute_rd, HDUnit_if.ra_use, HDUnit_if.decode_ra, HDUnit_if.rb_use, HDUnit_if.decode_rb);
        // $display("----DECODE----");
        // $display("PC: %h, write: %h", D_tlb_exception.pc, execute_if.commit.mem_write);
        // $display("----EXECUTE----");
        // $display("PC: %h, write: %h, addr: %h", E_tlb_exception.pc, E_write, commit_if.alu_result);
        // $display("op1: %h, op2: %h, ra value: %h, rb value %h", execute.op1_value, execute.op2_value, execute.ra_value, execute.rb_value);
        // $display("----FWUNIT----");
        // $display("fw ra id: %h, fw rb id: %h, fw rd_commit: %h, fw wb commit; %h", FWUnit_if.ra_execute_id, FWUnit_if.rb_execute_id, FWUnit_if.ra_execute_bypass[1], FWUnit_if.ra_execute_bypass[0]);
        // $display("alu ra: %h, alu rb: %h, bypass ra commit: %h, bypass ra wb; %hb, bypass rb commit: %h, bypass rb wb; %h", FWUnit_if.ra_execute_id, FWUnit_if.rb_execute_id, FWUnit_if.ra_execute_bypass[1], FWUnit_if.ra_execute_bypass[0], FWUnit_if.rb_execute_bypass[1], FWUnit_if.rb_execute_bypass[0]);
        // $display("commit id: %h, commit write enable; %h, commit: value: %h", FWUnit_if.rd_commit, FWUnit_if.writeback_commit, FWUnit_if.commit_value);
        // $display("wb id: %h, wb write enable; %h, wb: value: %h", FWUnit_if.rd_wb, FWUnit_if.writeback_wb, FWUnit_if.wb_value);

    end

endmodule
