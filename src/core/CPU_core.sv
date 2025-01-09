`include "CPU_define.vh"
`include "core/CPU_fetch.sv"
`include "core/CPU_commit.sv"
`include "cache/CPU_cache_types.svh"
`include "cache/interfaces/CPU_mem_bus_request_if.sv"
`include "cache/interfaces/CPU_mem_bus_response_if.sv"
`include "mem/MEM_core_bus_request_if.sv"
`include "mem/MEM_core_bus_response_if.sv"

module CPU_core
(
    input wire clock,
    input wire reset,

    MEM_core_bus_request_if.request mem_bus_request,
    MEM_core_bus_request_if.response mem_bus_response
);

    // Pipeline registers
    logic [`VIRTUAL_ADDR_WIDTH-1:0] F_pc;
    logic F_usermode;

    logic D_nop;
    tlb_exception_t D_tlb_exception;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] D_pc;
    logic [`INSTR_WIDTH-1:0] D_instr;

    tlb_exception_t E_tlb_exception;
    logic E_tlb_write;
    cache_mode_e E_mode;
    logic E_usermode;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] E_pc;

    tlb_exception_t C_tlb_exception;
    logic [`VIRTUAL_ADDR_WIDTH-1:0] C_pc;
    logic C_tlb_write;
    cache_mode_e C_mode;
    logic C_usermode;

    tlb_exception_t W_tlb_exception;
    logic W_hit;
    logic [$clog2(`NUM_REGS)-1:0] W_reg;
    logic [`REG_WIDTH-1:0] W_data;

    
    // Pipeline interfaces
    CPU_fetch_if fetch_if();
    CPU_decode_if decode_if();
    CPU_execute_if execute_if();
    CPU_commit_if commit_if();
    CPU_writeback_if writeback_if();

    assign fetch_if.pc = F_pc;
    assign fetch_if.exception = ~commit_if.tlb_hit && C_usermode == `SUPERUSER_MODE;
    
    assign F_usermode = execute_if.usermode_reg;
    
    assign decode_if.commit.addr = commit_if.cache_addr;
    assign decode_if.commit.tlb_hit = commit_if.tlb_hit;
    assign decode_if.nop = D_nop;
    assign decode_if.tlb_exception = W_tlb_exception;

    assign E_mode = execute_if.commit.mode;
    
    assign commit_if.write = commit_if.commit.mem_write; 
    assign commit_if.read = commit_if.commit.mem_read;
    assign commit_if.mode = C_mode;
    assign commit_if.data = commit_if.rb_value;
    assign commit_if.addr = commit_if.alu_result;
    
    // Memory interfaces
    CPU_mem_bus_request_if icache_mem_bus_request();
    CPU_mem_bus_request_if dcache_mem_bus_request();
    CPU_mem_bus_response_if icache_mem_bus_response();
    CPU_mem_bus_response_if dcache_mem_bus_response();

    // Memory module
    always_latch begin // TODO: maybe moveit to a module
        // request balancer
        if (dcache_mem_bus_request.read || dcache_mem_bus_request.write) begin
            mem_bus_request.id      <= 0;
            mem_bus_request.read    <= dcache_mem_bus_request.read;
            mem_bus_request.write   <= dcache_mem_bus_request.write;
            mem_bus_request.data    <= dcache_mem_bus_request.data;
            mem_bus_request.addr    <= dcache_mem_bus_request.addr;
        end else if (icache_mem_bus_request.read || icache_mem_bus_request.write) begin
            mem_bus_request.id      <= 1;
            mem_bus_request.read    <= icache_mem_bus_request.read;
            mem_bus_request.write   <= icache_mem_bus_request.write;
            mem_bus_request.data    <= icache_mem_bus_request.data;
            mem_bus_request.addr    <= icache_mem_bus_request.addr;
        end else begin
            mem_bus_request.read    <= 0;
            mem_bus_request.write   <= 0;
        end
        // response dispatcher
        if (mem_bus_response.valid) begin
            if (mem_bus_response.id == 0) begin
                dcache_mem_bus_response.valid   <= 1;
                dcache_mem_bus_response.addr    <= mem_bus_response.addr;
                dcache_mem_bus_response.data    <= mem_bus_response.data;
            end else begin
                dcache_mem_bus_response.valid <= 0;
            end
            if (mem_bus_response.id == 0) begin
                icache_mem_bus_response.valid   <= 1;
                icache_mem_bus_response.addr    <= mem_bus_response.addr;
                icache_mem_bus_response.data    <= mem_bus_response.data;
            end else begin
                icache_mem_bus_response.valid <= 0;
            end
        end else begin
            dcache_mem_bus_response.valid <= 0;
            icache_mem_bus_response.valid <= 0;
        end
    end
    

    CPU_FWUnit_if FWUnit_if();
    CPU_HDUnit_if HDUnit_if();

    assign FWUnit_if.commit_value = commit_if.cache_data_out;

    CPU_FWUnit FWUnit
    (
        .clock(clock),
        .reset(reset),
        .FWUnit_if(FWUnit_if)
    );

    CPU_HDUnit HDUnit
    (
        .clock(clock),
        .reset(reset),
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
    assign bank_reg_if.reg_dest = W_reg;

    CPU_decode decode
    (
        .clock (clock),
        .reset (reset),
        .bank_reg_if (bank_reg_if),
        .decode_if (decode_if),
        .execute_if (execute_if)
    );

    CPU_execute execute
    (
        .clock (clock),
        .reset (reset),
        .execute_if (execute_if),
        .FWUnit_input_if (forward_unit_input_if),
        .FWUnit_output_if (forward_unit_output_if),
        .commit_if (commit_if),
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

    CPU_writeback writeback
    (
        .clock (clock),
        .reset (reset),
        .commit_if (commit_if),
        .FWUnit_input_if (forward_unit_input_if),
        .reg_write (reg_write),
        .write_register (write_register),
        .write_data (write_data)
    );

    // Registers logic

    always @(posedge clock) begin
        if ((C_read || C_write) && ~commit_if.cache_hit) begin // dcache miss behaviour
            if (~fetch_if.cache_hit) begin
                D_nop <= 1;
            end else begin
                D_nop <= 0;
            end
            if (fetch_if.cache_hit && ~HDUnit.stall) begin
                F_pc <= fetch_if.next_pc;
            end

            if (~HDUnit.stall) begin
                D_instr <= fetch_if.instr;
            end

            D_pc <= F_pc;
            D_tlb_exception.raise <= ~fetch_if.tlb_hit && F_usermode != `SUPERUSER_MODE;
            D_tlb_exception.vaddr <= fetch_if.tlb_addr;
            D_tlb_exception.pc <= fetch_if.pc;

            E_tlb_exception <= D_tlb_exception;
            E_tlb_write <= execute_if.tlb_write;
            E_usermode <= execute_if.rm4;
            E_pc <= D_pc;

            C_tlb_exception <= E_tlb_exception;
            C_pc <= E_pc;
            C_usermode <= E_usermode;
            C_mode <= E_mode;
            C_tlb_write <= E_tlb_write;

            if (~commit_if.tlb_hit && C_usermode != `SUPERUSER_MODE) begin
                W_tlb_exception.raise <= ~commit_if.tlb_hit && C_usermode != `SUPERUSER_MODE;
                W_tlb_exception.vaddr <= commit_if.cache_addr;
                W_tlb_exception.pc <= C_pc;
            end else begin
                W_tlb_exception <= C_tlb_exception;
            end
            W_write <= commit_if.writeback.write_enable && (~commit_if.writeback.mem_to_reg || commit_if.cache_hit);
            W_data <= commit_if.writeback.mem_to_reg ? commit_if.cache_data_out : C_addr;
            W_reg <= commit_if.reg_dest;
        end
    end

endmodule