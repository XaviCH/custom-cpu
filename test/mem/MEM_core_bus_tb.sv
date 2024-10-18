`include "CPU_define.vh"

module MEM_core_bus_tb ();
    
    reg clock;
    reg reset;

    MEM_core_request_if bus_request_if();
    MEM_core_response_if bus_response_if();

    MEM_core_request_if core_request_if();
    MEM_core_response_if core_response_if();

    MEM_core_bus memory_bus(
        .clock (clock),
        .reset (reset),
        .bus_request_if (bus_request_if),
        .core_request_if (core_request_if),
        .bus_response_if (bus_response_if),
        .core_response_if (core_response_if)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;
        // request program
        bus_request_if.read = '0; 
        bus_request_if.write = '1;
        bus_request_if.line_addr = 'h0;
        bus_request_if.line_data = `LINE_WIDTH'hAAAAAAAA;
        core_response_if.valid = '1;
        core_response_if.line_data = `LINE_WIDTH'hAAAAAAAA;
        $display("bus_response. valid: %b, line data: %h", bus_response_if.valid, bus_response_if.line_data);
        $display("core_request: read: %b, write: %b, line_addr: %h, line data: %h", core_request_if.read, core_request_if.write, core_request_if.line_addr, core_request_if.line_data);
        #20
        bus_request_if.read = '1; 
        bus_request_if.write = '0;
        bus_request_if.line_addr = 'h1;
        bus_request_if.line_data = `LINE_WIDTH'hBBBBBBBB;
        core_response_if.valid = '1;
        core_response_if.line_data = `LINE_WIDTH'hBBBBBBBB;
        $display("bus_response. valid: %b, line data: %h", bus_response_if.valid, bus_response_if.line_data);
        $display("core_request: read: %b, write: %b, line_addr: %h, line data: %h", core_request_if.read, core_request_if.write, core_request_if.line_addr, core_request_if.line_data);
        #20
        $display("bus_response. valid: %b, line data: %h", bus_response_if.valid, bus_response_if.line_data);
        $display("core_request: read: %b, write: %b, line_addr: %h, line data: %h", core_request_if.read, core_request_if.write, core_request_if.line_addr, core_request_if.line_data);
        #20
        $display("bus_response. valid: %b, line data: %h", bus_response_if.valid, bus_response_if.line_data);
        $display("core_request: read: %b, write: %b, line_addr: %h, line data: %h", core_request_if.read, core_request_if.write, core_request_if.line_addr, core_request_if.line_data);
        #20
        $display("bus_response. valid: %b, line data: %h", bus_response_if.valid, bus_response_if.line_data);
        $display("core_request: read: %b, write: %b, line_addr: %h, line data: %h", core_request_if.read, core_request_if.write, core_request_if.line_addr, core_request_if.line_data);
        #20
        $display("bus_response. valid: %b, line data: %h", bus_response_if.valid, bus_response_if.line_data);
        $display("core_request: read: %b, write: %b, line_addr: %h, line data: %h", core_request_if.read, core_request_if.write, core_request_if.line_addr, core_request_if.line_data);
        #20
        $display("bus_response. valid: %b, line data: %h", bus_response_if.valid, bus_response_if.line_data);
        $display("core_request: read: %b, write: %b, line_addr: %h, line data: %h", core_request_if.read, core_request_if.write, core_request_if.line_addr, core_request_if.line_data);
        #20
        $display("bus_response. valid: %b, line data: %h", bus_response_if.valid, bus_response_if.line_data);
        $display("core_request: read: %b, write: %b, line_addr: %h, line data: %h", core_request_if.read, core_request_if.write, core_request_if.line_addr, core_request_if.line_data);
        #20
        $finish();
    end

endmodule
