module CPU_core;
(
    input wire clock,
    input wire reset,
    // Memory maybe here??
);

// Pipeline registers
CPU_fetch_if fetch_if();
CPU_decode_if decode_if();
CPU_execute_if execute_if();
CPU_commit_if commit_if();
CPU_writeback_if writeback_if();

// Shared units
CPU_cache_request_if icache_request_if();
CPU_cache_response_if icache_response_if();
CPU_cache icache(
    .clock (clock),
    .reset (reset),
    .cache_request_if (icache_request_if),
    .cache_response_if (icache_response_if),
);

CPU_cache_request_if dcache_request_if();
CPU_cache_response_if dcache_response_if();
CPU_cache dcache(
    .clock (clock),
    .reset (reset),
    .cache_request_if (dcache_request_if),
    .cache_response_if (dcache_response_if),
);

CPU_bank_reg_if bank_reg_if();
CPU_bank_reg bank_reg(

);

CPU_FWUnit_if forward_unit_input_if();
CPU_FWUnit_if forward_unit_output_if();

CPU_FWUnit forward_unit(
    .FWUnit_input_if (forward_unit_input_if),
    .FWUnit_output_if (forward_unit_output_if)
);

// Pipeline declaration
CPU_fetch fetch
(
    .clock (clock),
    .reset (reset),
    .icache_request_if (icache_request_if),
    .icache_response_if (icache_response_if),
    .fetch_if (fetch_if),
    .execute_if (execute_if),
    .decode_if (decode_if),
);

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
    .commit_if (commit_if),
    .FWUnit_input_if (forward_unit_input_if),
    .writeback_if (writeback_if)
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

endmodule