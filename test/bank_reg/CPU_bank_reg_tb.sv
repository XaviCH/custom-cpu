`include "CPU_define.vh"

module CPU_bank_reg_tb ();
    
    reg clock;
    reg reset;

    CPU_bank_reg_if bank_request_if();

    CPU_bank_reg bank_reg(
        .clock (clock),
        .reset (reset),
        .request_if(bank_request_if),
        .response_if(bank_request_if)
    );

    always #10 clock <= ~clock;

    initial begin
        reset = 1;
        #20 // let reset a full cicle
        reset = 0;
        // load program
        bank_request_if.write_enable=1;
        bank_request_if.write_reg=2;
        bank_request_if.write_data=2;
        #20

        bank_request_if.read_reg_a=2;
        bank_request_if.read_reg_b=1;
        #20

    
        $display("reg a value: %h, reg b value: %h", bank_request_if.read_data_a, bank_request_if.slave.read_data_b);

        bank_request_if.write_enable=1;
        bank_request_if.write_reg=1;
        bank_request_if.write_data=20;
        #20

        bank_request_if.read_reg_a=2;
        bank_request_if.read_reg_b=1;
        #20

        $display("reg a value: %h, reg b value: %h", bank_request_if.read_data_a, bank_request_if.slave.read_data_b);

        // core_request_if.line_addr = 'h0;
        // core_request_if.line_data = `LINE_WIDTH'hAAAAAAAA;
        // $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        // #20
        // core_request_if.line_addr = 'h1;
        // core_request_if.line_data = `LINE_WIDTH'hBBBBBBBB;
        // $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        // #20
        // core_request_if.line_addr = 'h2;
        // core_request_if.line_data = `LINE_WIDTH'hCCCCCCCC;
        // $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        // #20
        // core_request_if.line_addr = 'h3;
        // core_request_if.line_data = `LINE_WIDTH'hDDDDDDDD;
        // $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        // #20
        // // read program
        // core_request_if.read = '1; 
        // core_request_if.write = '0;

        // core_request_if.line_addr = 'h0;
        // $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        // #20
        // core_request_if.line_addr = 'h1;
        // $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        // #20
        // core_request_if.line_addr = 'h2;
        // $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        // #20
        // core_request_if.line_addr = 'h3;
        // $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);
        // #20
        // $display("valid: %b, line data: %h", core_response_if.valid, core_response_if.line_data);

        $finish();
    end

endmodule
