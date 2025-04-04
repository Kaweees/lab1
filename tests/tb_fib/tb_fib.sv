module tb_fib;

// Declare test variables
logic clk;

// Instantiate Design 
// fib Fib (.*);

// Sample to drive clock
localparam CLK_PERIOD = 10;
always begin
    #(CLK_PERIOD/2) 
    clk<=~clk;
end

// Necessary to create Waveform
initial begin
    // Name as needed
    $dumpfile("tb_fib.vcd");
    $dumpvars(0);
end

initial begin
    // Test Goes Here

    // Make sure to call finish so test exits
    $finish();
end

endmodule
