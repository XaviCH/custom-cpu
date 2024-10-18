`include "CPU_define.vh"

module MEM_core_tb ();
    
    reg clock;
    reg reset;

    MEM_core_request_if core_request_if();
    MEM_core_response_if core_response_if();

    MEM_core memory_core(
        .clock (clock),
        .reset (reset),
        .core_request_if (core_request_if),
        .core_response_if (core_response_if)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;
        // load program
        core_request_if.read = '0; 
        core_request_if.write = '1;

        core_request_if.line_addr = 'h0;
        core_request_if.line_data = `LINE_WIDTH'hAAAAAAAA;
        $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        #20
        core_request_if.line_addr = 'h1;
        core_request_if.line_data = `LINE_WIDTH'hBBBBBBBB;
        $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        #20
        core_request_if.line_addr = 'h2;
        core_request_if.line_data = `LINE_WIDTH'hCCCCCCCC;
        $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        #20
        core_request_if.line_addr = 'h3;
        core_request_if.line_data = `LINE_WIDTH'hDDDDDDDD;
        $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        #20
        // read program
        core_request_if.read = '1; 
        core_request_if.write = '0;

        core_request_if.line_addr = 'h0;
        $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        #20
        core_request_if.line_addr = 'h1;
        $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        #20
        core_request_if.line_addr = 'h2;
        $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        #20
        core_request_if.line_addr = 'h3;
        $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        #20
        $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);

        $finish();
    end

endmodule
