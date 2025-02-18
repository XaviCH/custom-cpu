`ifndef CPU_DEFINE_TB_SVH
`define CPU_DEFINE_TB_SVH

`define SUCCESS \
    $display("SUCCESS."); \
    $finish();

`define ASSERT(signal) \
    if ((signal) !== 1) begin \
        $error("signal === %h", signal); \
    end

`define ASSERT_EQUAL(signal, value) \
    if (signal !== value) begin \
        $error("signal !== value : %h !== %h", signal, value); \
    end

`endif 
